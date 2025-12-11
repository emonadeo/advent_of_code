const std = @import("std");

pub fn part_01(gpa: std.mem.Allocator, lines: []const []const u8) !u64 {
    var points = try Point.parseMany(gpa, lines);
    defer points.deinit(gpa);

    var connections: Connections = try .fromPoints(gpa, points.items);
    defer connections.deinit();

    var network: Network = .init(gpa);
    defer network.deinit();

    for (0..1000) |_| {
        const connection = connections.queue.remove();
        try network.insert(connection);
    }

    var sum: usize = 1;
    for (0..3) |_| {
        var circuit = network.circuits.remove();
        defer circuit.deinit(gpa);
        sum *= circuit.items.len;
    }
    return sum;
}

pub fn part_02(lines: []const []const u8) !u64 {
    _ = lines;
    return 0;
}

fn orderPoints(_: void, a: Point, b: Point) std.math.Order {
    const xs = std.math.order(a.x, b.x);
    if (xs != .eq) return xs;
    const ys = std.math.order(a.y, b.y);
    if (ys != .eq) return ys;
    const zs = std.math.order(a.z, b.z);
    if (zs != .eq) return zs;
    return .eq;
}

const Point = struct {
    x: u32,
    y: u32,
    z: u32,

    const Self = @This();

    pub fn parse(buf: []const u8) error{ Overflow, InvalidCharacter }!Self {
        var split = std.mem.splitScalar(u8, buf, ',');
        const x = try std.fmt.parseInt(u32, split.next() orelse return error.InvalidCharacter, 10);
        const y = try std.fmt.parseInt(u32, split.next() orelse return error.InvalidCharacter, 10);
        const z = try std.fmt.parseInt(u32, split.next() orelse return error.InvalidCharacter, 10);
        if (split.next() != null) return error.InvalidCharacter;
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn parseMany(gpa: std.mem.Allocator, bufs: []const []const u8) !std.ArrayList(Point) {
        var points: std.ArrayList(Point) = try .initCapacity(gpa, bufs.len);
        for (bufs) |buf| points.appendAssumeCapacity(try Point.parse(buf));
        return points;
    }

    pub fn distanceEuclidean(self: Self, other: Self) f64 {
        const dx = @as(i64, @intCast(self.x)) - @as(i64, @intCast(other.x));
        const dy = @as(i64, @intCast(self.y)) - @as(i64, @intCast(other.y));
        const dz = @as(i64, @intCast(self.z)) - @as(i64, @intCast(other.z));
        return @as(f64, @floatFromInt(dx * dx + dy * dy + dz * dz));
    }

    pub fn print(self: Self) void {
        std.debug.print("({},{},{})", .{ self.x, self.y, self.z });
    }
};

const Connection = struct {
    start: Point,
    end: Point,

    const Self = @This();

    pub fn distanceEuclidean(self: Self) f64 {
        return self.start.distanceEuclidean(self.end);
    }
};

fn orderDistanceEuclideanAsc(_: void, a: Connection, b: Connection) std.math.Order {
    return std.math.order(a.distanceEuclidean(), b.distanceEuclidean());
}

const Connections = struct {
    queue: std.PriorityQueue(Connection, void, orderDistanceEuclideanAsc),

    const Self = @This();

    // Assumes that `points` does not contain repetitions.
    pub fn fromPoints(gpa: std.mem.Allocator, points: []const Point) !Self {
        var queue: @FieldType(Self, "queue") = .init(gpa, {});
        for (points, 0..) |a, i| {
            for (points[(i + 1)..]) |b| {
                // PERF: Use `ensureTotalCapacity` to minimize allocations
                try queue.add(.{ .start = a, .end = b });
            }
        }
        return .{ .queue = queue };
    }

    pub fn deinit(self: *Self) void {
        self.queue.deinit();
    }
};

const Circuit = std.ArrayList(Point);

fn orderConnectionCountDesc(_: void, a: Circuit, b: Circuit) std.math.Order {
    const length_order = std.math.order(b.items.len, a.items.len);
    if (length_order == .eq) {
        // For circuits with the same amount of connections we compare the first point
        // which is guarantueed to be unique as a point can only belong to a single circuit
        const a_first = a.items[0];
        const b_first = b.items[0];
        return orderPoints({}, b_first, a_first);
    }
    return length_order;
}

const Network = struct {
    circuits: std.PriorityQueue(Circuit, void, orderConnectionCountDesc),
    cache: std.AutoArrayHashMap(Point, usize),
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(gpa: std.mem.Allocator) Self {
        return .{
            .circuits = .init(gpa, {}),
            .cache = .init(gpa),
            .allocator = gpa,
        };
    }

    fn deinit(self: *Self) void {
        for (0..self.circuits.items.len) |i| self.circuits.items[i].deinit(self.allocator);
        self.circuits.deinit();
        self.cache.deinit();
        return {};
    }

    fn getCircuitIndex(self: *Self, point: Point) !?usize {
        // INFO: Sanity check. Can be removed
        var iter = self.cache.iterator();
        blk: while (iter.next()) |entry| {
            const points = self.circuits.items[entry.value_ptr.*];
            for (points.items) |p| {
                if (p.x == entry.key_ptr.*.x and p.y == entry.key_ptr.*.y and p.z == entry.key_ptr.*.z) {
                    continue :blk;
                }
            }
            unreachable;
        }

        if (self.cache.get(point)) |index| return index;
        for (0..self.circuits.items.len) |index| {
            const points = self.circuits.items[index];
            for (points.items) |ex| {
                if (ex.x == point.x and ex.y == point.y and ex.z == point.z) {
                    try self.cache.put(point, index);
                    return index;
                }
            }
        }
        return null;
    }

    fn insert(self: *Self, connection: Connection) !void {
        const start = connection.start;
        const end = connection.end;
        if (try self.getCircuitIndex(start)) |start_index| {
            if (try self.getCircuitIndex(end)) |end_index| {
                // Are the points already connected?
                if (start_index == end_index) {
                    // std.debug.print(
                    //     "A circuit containing {},{},{} - {},{},{} already exists. Skipping.\n",
                    //     .{ start.x, start.y, start.z, end.x, end.y, end.z },
                    // );
                    return {};
                }

                // std.debug.print(
                //     "{},{},{} - {},{},{} connects two circuits. Merging.\n\n",
                //     .{ start.x, start.y, start.z, end.x, end.y, end.z },
                // );

                // INFO: Sanity check. Can be removed.
                for (self.circuits.items[start_index].items) |point| {
                    if (try self.getCircuitIndex(point) != start_index) {
                        std.debug.print("expected {any} to equal {}.\n", .{ try self.getCircuitIndex(point), start_index });
                        unreachable;
                    }
                }
                for (self.circuits.items[end_index].items) |point| {
                    if (try self.getCircuitIndex(point) != end_index) {
                        std.debug.print("expected {any} to equal {}.\n", .{ try self.getCircuitIndex(point), end_index });
                        unreachable;
                    }
                }

                // HACK: Merging seems to mess with the priority queue (but the tests pass).
                // Consider replacing priority queue with a no-frills list and sort it once.

                // Circuit containing `start` absorbs the circuit containing `end`
                var start_circuit = self.circuits.items[start_index];
                defer start_circuit.deinit(self.allocator);
                var end_circuit = self.circuits.removeIndex(end_index);
                // To save allocations we can mutate the circuit containing `end`.
                // Copy circuit containing `start` into the circuit containing `end`.
                try end_circuit.appendSlice(self.allocator, start_circuit.items);
                try self.circuits.update(start_circuit, end_circuit);

                // Invalidate cache
                self.cache.clearAndFree();

                // self.print();
                return {};
            } else {
                if (try self.getCircuitIndex(end) != null) unreachable;
                // std.debug.print(
                //     "Left point of {},{},{} - {},{},{} is part of existing circuit. Appending right point to it.\n\n",
                //     .{ start.x, start.y, start.z, end.x, end.y, end.z },
                // );
                try self.circuits.items[start_index].append(self.allocator, end);
                // self.print();
                return {};
            }
        } else if (try self.getCircuitIndex(end)) |end_index| {
            if (try self.getCircuitIndex(start) != null) unreachable;
            // std.debug.print(
            //     "Right point of {},{},{} - {},{},{} is part of existing circuit. Appending left point to it.\n\n",
            //     .{ start.x, start.y, start.z, end.x, end.y, end.z },
            // );
            try self.circuits.items[end_index].append(self.allocator, start);
            try self.cache.put(start, end_index);
            // self.print();
            return {};
        }

        if (try self.getCircuitIndex(start) != null or
            try self.getCircuitIndex(end) != null) unreachable;
        // std.debug.print(
        //     "Neither left or right point of {},{},{} - {},{},{} exists. Creating a new circuit.\n\n",
        //     .{ start.x, start.y, start.z, end.x, end.y, end.z },
        // );
        var circuit: Circuit = .empty;
        try circuit.appendSlice(self.allocator, &[_]Point{ start, end });
        try self.circuits.add(circuit);
        self.cache.clearAndFree();
        // self.print();
    }

    fn print(self: Self) void {
        std.debug.print("CIRCUITS ({}):\n", .{self.circuits.items.len});
        for (self.circuits.items, 0..) |circuit, i| {
            std.debug.print("Circuit {}: ", .{i});
            for (circuit.items) |point| {
                point.print();
                std.debug.print(", ", .{});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("CACHE ({}):\n", .{self.cache.count()});
        var iter = self.cache.iterator();
        while (iter.next()) |entry| {
            entry.key_ptr.print();
            std.debug.print(" -> ", .{});
            for (self.circuits.items[entry.value_ptr.*].items) |point| {
                point.print();
                std.debug.print(", ", .{});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};

test "testExample" {
    const lines = [_][]const u8{
        "162,817,812",
        "57,618,57",
        "906,360,560",
        "592,479,940",
        "352,342,300",
        "466,668,158",
        "542,29,236",
        "431,825,988",
        "739,650,466",
        "52,470,668",
        "216,146,977",
        "819,987,18",
        "117,168,530",
        "805,96,715",
        "346,949,466",
        "970,615,88",
        "941,993,340",
        "862,61,35",
        "984,92,344",
        "425,690,689",
    };

    var points = try Point.parseMany(std.testing.allocator, &lines);
    defer points.deinit(std.testing.allocator);

    var connections: Connections = try .fromPoints(std.testing.allocator, points.items);
    defer connections.deinit();

    var network: Network = .init(std.testing.allocator);
    defer network.deinit();

    // for (connections.queue.items) |connection| {
    //     std.debug.print("{} = ", .{connection.distanceEuclidean()});
    //     connection.start.print();
    //     std.debug.print(" - ", .{});
    //     connection.end.print();
    //     std.debug.print("\n", .{});
    // }

    for (0..10) |_| {
        const connection = connections.queue.remove();
        try network.insert(connection);
    }

    var sum: usize = 1;
    for (0..3) |_| {
        var circuit = network.circuits.remove();
        defer circuit.deinit(std.testing.allocator);
        sum *= circuit.items.len;
    }

    try std.testing.expectEqual(40, sum);
}
