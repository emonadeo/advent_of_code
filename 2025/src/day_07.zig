const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    const width = lines[0].len;
    var columns: std.AutoArrayHashMap(usize, void) = .init(gpa);
    defer columns.deinit();

    for (lines[0], 0..) |char, column| {
        if (char == 'S') {
            try columns.put(column, {});
        }
    }
    var splits: u64 = 0;
    for (lines[1..]) |line| {
        const columns_copy = try gpa.dupe(usize, columns.keys());
        defer gpa.free(columns_copy);
        for (columns_copy) |column| {
            if (line[column] == '^') {
                splits += 1;
                if (!columns.swapRemove(column)) {
                    unreachable;
                }
                const right = column + 1;
                if (right >= width) unreachable;
                if (column <= 0) unreachable;

                try columns.put(right, {});
                try columns.put(column - 1, {});
            }
        }
    }
    if (columns.count() == 0) unreachable;
    return splits;
}

pub fn part_02(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    const column = blk: {
        for (lines[0], 0..) |char, column| {
            if (char == 'S') break :blk column;
        }
        unreachable;
    };

    var memory: std.AutoArrayHashMap(Point, u64) = .init(gpa);
    defer memory.deinit();
    return countTimelines(lines, .{ .row = 0, .column = column }, &memory);
}

pub fn countTimelines(
    lines: []const []const u8,
    point: Point,
    memory: *std.AutoArrayHashMap(Point, u64),
) !u64 {
    if (memory.get(point)) |result| return result;

    for (lines[point.row + 1 ..], (point.row + 1)..) |line, row| {
        if (line[point.column] == '^') {
            const left: Point = .{ .row = row, .column = point.column - 1 };
            const left_count = try countTimelines(lines, left, memory);
            try memory.put(left, left_count);
            const right: Point = .{ .row = row, .column = point.column + 1 };
            const right_count = try countTimelines(lines, right, memory);
            try memory.put(right, right_count);

            return left_count + right_count;
        }
    }

    return 1;
}

const Point = struct {
    row: usize,
    column: usize,
};

test "testExample" {
    const lines = [_][]const u8{
        ".......S.......",
        "...............",
        ".......^.......",
        "...............",
        "......^.^......",
        "...............",
        ".....^.^.^.....",
        "...............",
        "....^.^...^....",
        "...............",
        "...^.^...^.^...",
        "...............",
        "..^...^.....^..",
        "...............",
        ".^.^.^.^.^...^.",
        "...............",
    };

    try std.testing.expectEqual(21, try part_01(&lines));
    try std.testing.expectEqual(40, try part_02(&lines));
}
