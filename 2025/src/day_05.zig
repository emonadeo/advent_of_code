const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const a = arena.allocator();

    var ranges: Ranges = .{};
    var split: usize = 0;
    for (lines, 0..) |line, i| {
        if (std.mem.eql(u8, line, "")) {
            split = i + 1;
            break;
        }

        const range = try a.create(Range);
        range.* = try parseRange(line);
        try ranges.append(range);
    }

    var sum: u64 = 0;
    for (lines[split..]) |line| {
        const ingredient = try std.fmt.parseInt(u64, line, 10);
        if (ranges.contains(ingredient)) {
            sum += 1;
        }
    }

    return sum;
}

const Ranges = struct {
    const Self = @This();

    list: std.DoublyLinkedList = .{},

    pub fn first(self: *const Self) ?*Range {
        if (self.list.first) |first_node| {
            return @fieldParentPtr("node", first_node);
        }
        return null;
    }

    pub fn appendSimple(self: *Self, range: *Range) void {
        self.list.append(&range.node);
    }

    pub fn append(self: *Self, range: *Range) !void {
        var it = self.list.first;

        while (it) |node| : (it = node.next) {
            const existing: *Range = @fieldParentPtr("node", node);

            // Range to insert is fully included in an existing range.
            if (range.min >= existing.min and range.max <= existing.max) {
                return {};
            }

            // Find overlap
            if ((range.min <= existing.min and range.max >= existing.min) or (range.min <= existing.max and range.max >= existing.max)) {
                // std.debug.print("Merge overlap of new node {}-{} and existing node {}-{}\n", .{ range.min, range.max, existing.min, existing.max });

                // Append existing range instead of adding a new range.
                if (range.max > existing.max) {
                    existing.max = range.max;
                }
                if (range.min < existing.min) {
                    existing.min = range.min;
                }

                // Merge succeeding nodes
                var successor_node_opt = existing.node.next;
                while (successor_node_opt) |successor_node| : (successor_node_opt = successor_node.next) {
                    const successor: *Range = @fieldParentPtr("node", successor_node);
                    if (existing.max < successor.min) {
                        // Not connected
                        break;
                    }
                    if (successor.max > existing.max) {
                        existing.max = successor.max;
                    }
                    self.list.remove(successor_node);
                }

                // Merge preceding nodes
                var preceding_node_opt = existing.node.prev;
                while (preceding_node_opt) |preceding_node| : (preceding_node_opt = preceding_node.prev) {
                    const predecessor: *Range = @fieldParentPtr("node", preceding_node);
                    if (predecessor.max < existing.min) {
                        // Not connected
                        break;
                    }
                    if (predecessor.min < existing.min) {
                        existing.min = predecessor.min;
                    }
                    self.list.remove(preceding_node);
                }

                return {};
            }

            if (range.min > existing.max) {
                const next_node_opt = node.next;
                if (next_node_opt) |next_node| {
                    const existing_next: *Range = @fieldParentPtr("node", next_node);
                    if (range.max < existing_next.min) {
                        // std.debug.print("Insert {}-{} after {}-{}.\n", .{ range.min, range.max, existing.min, existing.max });
                        self.list.insertAfter(&existing.node, &range.node);
                        return {};
                    }
                } else {
                    // std.debug.print("Append {}-{} to the end of the list.\n", .{ range.min, range.max });
                    self.list.append(&range.node);
                    return {};
                }
            }
        }

        // std.debug.print("Prepend {}-{} to the start of the list.\n", .{ range.min, range.max });
        self.list.prepend(&range.node);
    }

    pub fn contains(self: *Self, value: u64) bool {
        var node_opt = self.list.first;
        while (node_opt) |node| : (node_opt = node.next) {
            const range: *Range = @fieldParentPtr("node", node);
            if (value >= range.min and value <= range.max) {
                return true;
            }
        }
        return false;
    }
};

// `min` has to be smaller than `max`.
// Ranges with `min` > `max` are undefined behavior.
const Range = struct {
    min: u64,
    max: u64,
    node: std.DoublyLinkedList.Node = .{},
};

pub fn parseRange(line: []const u8) !Range {
    var split = std.mem.splitScalar(u8, line, '-');
    const min_str = split.next() orelse return error.InvalidChar;
    const max_str = split.next() orelse return error.InvalidChar;
    const min = try std.fmt.parseInt(u64, min_str, 10);
    const max = try std.fmt.parseInt(u64, max_str, 10);
    return Range{ .min = min, .max = max };
}

test "testExample" {
    const lines = [_][]const u8{
        "3-5",
        "10-14",
        "16-20",
        "12-18",
        "",
        "1",
        "5",
        "8",
        "11",
        "17",
        "32",
    };

    try std.testing.expectEqual(3, try part_01(&lines));
}

test "testAppend" {
    var ranges: Ranges = .{};

    var one: Range = .{ .min = 3, .max = 5 };
    try ranges.append(&one);

    var range = ranges.first() orelse unreachable;
    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);

    var two: Range = .{ .min = 10, .max = 14 };
    try ranges.append(&two);

    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(10, range.min);
    try std.testing.expectEqual(14, range.max);
    try std.testing.expectEqual(null, range.node.next);

    var three: Range = .{ .min = 16, .max = 20 };
    try ranges.append(&three);

    range = ranges.first() orelse unreachable;
    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(10, range.min);
    try std.testing.expectEqual(14, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(16, range.min);
    try std.testing.expectEqual(20, range.max);
    try std.testing.expectEqual(null, range.node.next);

    var four: Range = .{ .min = 12, .max = 18 };
    try ranges.append(&four);

    range = ranges.first() orelse unreachable;
    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(10, range.min);
    try std.testing.expectEqual(20, range.max);
    try std.testing.expectEqual(null, range.node.next);

    var five: Range = .{ .min = 21, .max = 25 };
    try ranges.append(&five);

    range = ranges.first() orelse unreachable;
    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(10, range.min);
    try std.testing.expectEqual(20, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(21, range.min);
    try std.testing.expectEqual(25, range.max);
    try std.testing.expectEqual(null, range.node.next);

    var six: Range = .{ .min = 1, .max = 2 };
    try ranges.append(&six);

    range = ranges.first() orelse unreachable;
    try std.testing.expectEqual(1, range.min);
    try std.testing.expectEqual(2, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(3, range.min);
    try std.testing.expectEqual(5, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(10, range.min);
    try std.testing.expectEqual(20, range.max);
    range = @fieldParentPtr("node", range.node.next orelse unreachable);
    try std.testing.expectEqual(21, range.min);
    try std.testing.expectEqual(25, range.max);
    try std.testing.expectEqual(null, range.node.next);
}
