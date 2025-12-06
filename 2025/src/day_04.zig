const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var papers = try parsePapers(gpa, lines);
    defer papers.deinit();
    return countAccessiblePapers(papers);
}

pub fn part_02(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var papers = try parsePapers(gpa, lines);
    defer papers.deinit();
    return removeAccessiblePapers(&papers, 0);
}

const Point = struct {
    row: usize,
    column: usize,
};

const Cell = enum {
    empty,
    paper,
};

pub fn parseCell(grapheme: u8) error{InvalidChar}!Cell {
    return switch (grapheme) {
        '.' => Cell.empty,
        '@' => Cell.paper,
        else => error.InvalidChar,
    };
}

pub fn parsePapers(gpa: std.mem.Allocator, lines: []const []const u8) !std.AutoArrayHashMap(Point, void) {
    var grid = std.AutoArrayHashMap(Point, void).init(gpa);
    for (lines, 0..) |line, row| {
        for (line, 0..) |grapheme, column| {
            if (try parseCell(grapheme) == Cell.paper) {
                try grid.put(.{ .column = column, .row = row }, {});
            }
        }
    }
    return grid;
}

pub fn isPaperAccessible(papers: std.AutoArrayHashMap(Point, void), paper: Point) bool {
    const adjacents = if (paper.row == 0 and paper.column == 0) &[_]Point{
        Point{ .row = 0, .column = 1 },
        Point{ .row = 1, .column = 0 },
        Point{ .row = 1, .column = 1 },
    } else if (paper.row == 0) &[_]Point{
        Point{ .row = 0, .column = paper.column - 1 },
        Point{ .row = 0, .column = paper.column + 1 },
        Point{ .row = 1, .column = paper.column - 1 },
        Point{ .row = 1, .column = paper.column },
        Point{ .row = 1, .column = paper.column + 1 },
    } else if (paper.column == 0) &[_]Point{
        Point{ .row = paper.row - 1, .column = 0 },
        Point{ .row = paper.row - 1, .column = 1 },
        Point{ .row = paper.row, .column = 1 },
        Point{ .row = paper.row + 1, .column = 0 },
        Point{ .row = paper.row + 1, .column = 1 },
    } else &[_]Point{
        Point{ .row = paper.row - 1, .column = paper.column - 1 },
        Point{ .row = paper.row - 1, .column = paper.column },
        Point{ .row = paper.row - 1, .column = paper.column + 1 },
        Point{ .row = paper.row, .column = paper.column - 1 },
        Point{ .row = paper.row, .column = paper.column + 1 },
        Point{ .row = paper.row + 1, .column = paper.column - 1 },
        Point{ .row = paper.row + 1, .column = paper.column },
        Point{ .row = paper.row + 1, .column = paper.column + 1 },
    };

    var count: u8 = 0;
    for (adjacents) |adjacent| {
        if (papers.contains(adjacent)) {
            if (count == 3) {
                return false;
            }
            count += 1;
        }
    }
    return true;
}

pub fn countAccessiblePapers(papers: std.AutoArrayHashMap(Point, void)) !u64 {
    var count: u64 = 0;
    for (papers.keys()) |paper| {
        if (isPaperAccessible(papers, paper)) {
            count += 1;
        }
    }
    return count;
}

pub fn removeAccessiblePapers(papers: *std.AutoArrayHashMap(Point, void), removed: u64) u64 {
    var removed_iteration: u64 = 0;
    for (papers.keys()) |paper| {
        if (isPaperAccessible(papers.*, paper)) {
            if (papers.swapRemove(paper)) {
                removed_iteration += 1;
            } else {
                // HACK: This should be unreachable, but somehow it is reached.
            }
        }
    }
    if (removed_iteration == 0) {
        return removed;
    }
    return removeAccessiblePapers(papers, removed + removed_iteration);
}

test "testCountAccessiblePapers" {
    const lines = [_][]const u8{
        "..@@.@@@@.",
        "@@@.@.@.@@",
        "@@@@@.@.@@",
        "@.@@@@..@.",
        "@@.@@@@.@@",
        ".@@@@@@@.@",
        ".@.@.@.@@@",
        "@.@@@.@@@@",
        ".@@@@@@@@.",
        "@.@.@@@.@.",
    };

    var papers = try parsePapers(std.testing.allocator, &lines);
    defer papers.deinit();

    try std.testing.expectEqual(13, try countAccessiblePapers(papers));
}

test "testRemoveAccessiblePapers" {
    const lines = [_][]const u8{
        "..@@.@@@@.",
        "@@@.@.@.@@",
        "@@@@@.@.@@",
        "@.@@@@..@.",
        "@@.@@@@.@@",
        ".@@@@@@@.@",
        ".@.@.@.@@@",
        "@.@@@.@@@@",
        ".@@@@@@@@.",
        "@.@.@@@.@.",
    };

    var papers = try parsePapers(std.testing.allocator, &lines);
    defer papers.deinit();

    try std.testing.expectEqual(43, removeAccessiblePapers(&papers, 0));
}
