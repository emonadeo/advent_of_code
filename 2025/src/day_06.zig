const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var operations = try Operation.parseMany(gpa, lines[lines.len - 1]);
    defer operations.deinit(gpa);

    var results = try parseRow(gpa, lines[0]);
    defer results.deinit(gpa);
    for (lines[1 .. lines.len - 1]) |line| {
        var row = try parseRow(gpa, line);
        var i: usize = 0;
        while (i < row.items.len) : (i += 1) {
            switch (operations.items[i]) {
                .add => results.items[i] += row.items[i],
                .multiply => results.items[i] *= row.items[i],
            }
        }
        defer row.deinit(gpa);
    }

    var sum: u64 = 0;
    for (results.items) |result| {
        sum += result;
    }
    return sum;
}

pub fn part_02(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var operations = try Operation.parseMany(gpa, lines[lines.len - 1]);
    defer operations.deinit(gpa);

    var sum: u64 = 0;
    var problem: usize = 0;
    var result: u64 = operations.items[problem].identity();
    var column: usize = 0;
    while (column < lines[0].len) : (column += 1) {
        var number: u64 = 0;
        var exponent: u64 = 0;
        // row is 1-indexed to avoid unsigned integer overflow at 0
        var row: usize = lines.len - 1;
        while (row > 0) : (row -= 1) {
            // column is 0-indexed though (cry about it)
            if (lines[row - 1][column] == ' ') continue;
            const digit = try std.fmt.charToDigit(lines[row - 1][column], 10);
            number += digit * std.math.pow(u64, 10, exponent);
            exponent += 1;
        }

        if (exponent != 0) {
            switch (operations.items[problem]) {
                .add => result += number,
                .multiply => result *= number,
            }
            continue;
        }

        // Column consists only of spaces (exponent is 0).
        // Add result to sum and advance to next problem.
        sum += result;
        problem += 1;
        if (problem >= operations.items.len) {
            if (column >= lines[0].len) unreachable;
            break;
        }
        result = operations.items[problem].identity();
    }
    sum += result;

    return sum;
}

pub fn parseRow(gpa: std.mem.Allocator, line: []const u8) !std.ArrayList(u64) {
    var row: std.ArrayList(u64) = .empty;
    var i: usize = 0;
    var j: ?usize = null;
    while (i < line.len) : (i += 1) {
        if (line[i] == ' ') {
            if (j) |j_| {
                try row.append(gpa, try std.fmt.parseInt(u64, line[j_..i], 10));
                j = null;
            }
            continue;
        }
        if (j == null) {
            j = i;
        }
    }
    if (j) |j_| {
        try row.append(gpa, try std.fmt.parseInt(u64, line[j_..i], 10));
    }
    return row;
}

const Operation = enum {
    add,
    multiply,

    const Self = @This();

    pub fn parse(char: u8) error{InvalidCharacter}!Self {
        return switch (char) {
            '+' => .add,
            '*' => .multiply,
            else => error.InvalidCharacter,
        };
    }

    pub fn parseMany(gpa: std.mem.Allocator, line: []const u8) !std.ArrayList(Self) {
        var operations: std.ArrayList(Self) = .empty;
        for (line) |char| {
            if (char == ' ') continue;
            try operations.append(gpa, try parse(char));
        }
        return operations;
    }

    pub fn identity(self: Self) u64 {
        return switch (self) {
            .add => 0,
            .multiply => 1,
        };
    }
};

test "testParseRow" {
    var row = try parseRow(std.testing.allocator, "69    420 1");
    defer row.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices(u64, &[_]u64{ 69, 420, 1 }, row.items);
}

test "testParseOperations" {
    var row = try Operation.parseMany(std.testing.allocator, "+    * *");
    defer row.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices(Operation, &[_]Operation{ .add, .multiply, .multiply }, row.items);
}

test "testExample" {
    const lines = [_][]const u8{
        "123 328  51 64 ",
        " 45 64  387 23 ",
        "  6 98  215 314",
        "*   +   *   +",
    };

    try std.testing.expectEqual(4277556, try part_01(&lines));
    try std.testing.expectEqual(3263827, try part_02(&lines));
}
