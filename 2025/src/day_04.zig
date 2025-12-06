const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var papers = try parseGrid(gpa, lines);
    defer papers.deinit();
    return countAccessiblePapers(papers);
}

const Point = struct {
    row: usize,
    column: usize,

    pub fn adjacents(self: Point, gpa: std.mem.Allocator) error{OutOfMemory}![]Point {
        if (self.row == 0 and self.column == 0) {
            return gpa.dupe(Point, &[_]Point{
                Point{ .row = 0, .column = 1 },
                Point{ .row = 1, .column = 0 },
                Point{ .row = 1, .column = 1 },
            });
        }
        if (self.row == 0) {
            return gpa.dupe(Point, &[_]Point{
                Point{ .row = 0, .column = self.column - 1 },
                Point{ .row = 0, .column = self.column + 1 },
                Point{ .row = 1, .column = self.column - 1 },
                Point{ .row = 1, .column = self.column },
                Point{ .row = 1, .column = self.column + 1 },
            });
        }
        if (self.column == 0) {
            return gpa.dupe(Point, &[_]Point{
                Point{ .row = self.row - 1, .column = 0 },
                Point{ .row = self.row - 1, .column = 1 },
                Point{ .row = self.row, .column = 1 },
                Point{ .row = self.row + 1, .column = 0 },
                Point{ .row = self.row + 1, .column = 1 },
            });
        }
        return gpa.dupe(Point, &[_]Point{
            Point{ .row = self.row - 1, .column = self.column - 1 },
            Point{ .row = self.row - 1, .column = self.column },
            Point{ .row = self.row - 1, .column = self.column + 1 },
            Point{ .row = self.row, .column = self.column - 1 },
            Point{ .row = self.row, .column = self.column + 1 },
            Point{ .row = self.row + 1, .column = self.column - 1 },
            Point{ .row = self.row + 1, .column = self.column },
            Point{ .row = self.row + 1, .column = self.column + 1 },
        });
    }
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

pub fn parseGrid(gpa: std.mem.Allocator, lines: []const []const u8) !std.AutoArrayHashMap(Point, void) {
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

pub fn countAccessiblePapers(papers: std.AutoArrayHashMap(Point, void)) !u64 {
    var da = std.heap.DebugAllocator(.{}){};
    defer _ = da.deinit();
    var gpa = da.allocator();

    var count: u64 = 0;
    outer: for (papers.keys()) |paper| {
        var adjacent_count: u64 = 0;
        const adjacents = try paper.adjacents(gpa);
        defer gpa.free(adjacents);
        for (adjacents) |adjacent| {
            if (papers.contains(adjacent)) {
                adjacent_count += 1;
                if (adjacent_count == 4) {
                    continue :outer;
                }
            }
        }

        // std.debug.print("Point: {},{} has {} adjacent papers\n", .{ paper.row, paper.column, adjacent_count });
        count += 1;
    }
    return count;
}

test "testExample" {
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

    var grid = try parseGrid(std.testing.allocator, &lines);
    defer grid.deinit();

    try std.testing.expectEqual(13, try countAccessiblePapers(grid));
}
