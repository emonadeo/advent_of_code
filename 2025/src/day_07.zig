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
                if (right < width) {
                    try columns.put(right, {});
                }
                if (column > 0) {
                    try columns.put(column - 1, {});
                }
            }
        }
    }
    if (columns.count() == 0) unreachable;
    return splits;
}

pub fn part_02(lines: []const []const u8) !u64 {
    _ = lines;
    return 0;
}

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
}
