const std = @import("std");

pub fn part_01(gpa: std.mem.Allocator, lines: []const []const u8) !u64 {
    var sum: u64 = 0;
    for (lines) |line| {
        var split = std.mem.splitScalar(u8, line, ' ');

        var targets: State = try .parse(gpa, split.next() orelse unreachable);
        defer targets.deinit();

        var buttons: std.ArrayList(Button) = .empty;
        defer {
            for (0..buttons.items.len) |i| {
                buttons.items[i].deinit();
            }
            buttons.deinit(gpa);
        }

        while (split.next()) |segment| {
            if (segment[0] != '(') break;
            const button: Button = try .parse(gpa, segment);
            try buttons.append(gpa, button);
        }

        sum += 1;
    }

    return sum;
}

fn shortest(gpa: std.mem.Allocator, target: []const Status, buttons: []const Button) !u64 {
    var initial_state: std.ArrayList(Status) = try .initCapacity(gpa, target.len);
    defer initial_state.deinit(gpa);
    for (0..target.len) |_| {
        try initial_state.append(gpa, .off);
    }

    var steps: Steps = .init(gpa);
    defer steps.deinit();
    try steps.put(initial_state.items, 0);

    var queue: std.PriorityQueue(State, Steps, orderByStepsAsc) = .init(gpa, steps);
    defer queue.deinit();
    try queue.add(.{
        .lights = initial_state,
        .gpa = gpa,
    });

    while (queue.removeOrNull()) |state| {
        for (buttons) |button| {
            const cost = steps.get(state.lights.items) orelse unreachable;
            var s = state;
            (&s).toggle(button);
            if (!steps.contains(s.lights.items)) {
                try steps.put(s.lights.items, cost + 1);
                try queue.add(s);
            }
        }
    }

    return steps.get(target) orelse unreachable;
}

const Steps = std.ArrayHashMap([]const Status, u64, StatusContext, true);

const StatusContext = struct {
    const Self = @This();
    pub fn hash(_: Self, key: []const Status) u32 {
        var h: u32 = 0;
        for (key, 0..) |status, i| {
            const n = switch (status) {
                .off => 0,
                .on => 1,
            };
            h += n << i;
        }
        return std.hash.Murmur2_32.hashUint32(h);
    }

    pub fn eql(_: Self, a: []const Status, b: []const Status, _: usize) bool {
        return std.mem.eql(Status, a, b);
    }
};

fn orderByStepsAsc(steps: Steps, a: State, b: State) std.math.Order {
    return std.math.order(
        steps.get(a.lights.items) orelse unreachable,
        steps.get(b.lights.items) orelse unreachable,
    );
}

const Button = struct {
    indices: std.ArrayList(usize),
    gpa: std.mem.Allocator,

    const Self = @This();

    pub fn parse(gpa: std.mem.Allocator, buf: []const u8) !Self {
        var indices: std.ArrayList(usize) = .empty;
        var split = std.mem.splitScalar(u8, buf[1..(buf.len - 1)], ',');
        while (split.next()) |value| {
            try indices.append(gpa, try std.fmt.parseInt(u64, value, 10));
        }

        return .{
            .indices = indices,
            .gpa = gpa,
        };
    }

    pub fn deinit(self: *Self) void {
        self.indices.deinit(self.gpa);
    }
};

const State = struct {
    lights: std.ArrayList(Status),
    gpa: std.mem.Allocator,

    const Self = @This();

    pub fn parse(gpa: std.mem.Allocator, buf: []const u8) !Self {
        var lights = try std.ArrayList(Status).initCapacity(gpa, buf.len);
        for (buf[1..(buf.len - 1)]) |char| {
            lights.appendAssumeCapacity(try Status.parse(char));
        }

        return .{
            .lights = lights,
            .gpa = gpa,
        };
    }

    pub fn toggle(self: *Self, button: Button) void {
        for (button.indices.items) |index| {
            self.lights.items[index].toggle();
        }
    }

    pub fn deinit(self: *Self) void {
        self.lights.deinit(self.gpa);
    }
};

const Status = enum {
    on,
    off,

    const Self = @This();

    pub fn parse(char: u8) error{InvalidCharacter}!Self {
        return switch (char) {
            '.' => .off,
            '#' => .on,
            else => error.InvalidCharacter,
        };
    }

    pub fn toggle(self: *Self) void {
        self.* = switch (self) {
            .off => .on,
            .on => .off,
        };
    }
};

test "testExample" {
    const target = [_]Status{ .off, .on, .on, .off };
    const buttons = [_]Button{
        try .parse(std.testing.allocator, "(3)"),
        try .parse(std.testing.allocator, "(1,3)"),
        try .parse(std.testing.allocator, "(2)"),
        try .parse(std.testing.allocator, "(2,3)"),
        try .parse(std.testing.allocator, "(0,2)"),
        try .parse(std.testing.allocator, "(0,1)"),
    };
    try std.testing.expectEqual(2, shortest(std.testing.allocator, &target, &buttons));
}
