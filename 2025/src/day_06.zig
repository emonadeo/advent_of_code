const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var operations = try parseOperations(gpa, lines[lines.len - 1]);
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
};

pub fn parseOperation(char: u8) error{InvalidCharacter}!Operation {
    return switch (char) {
        '+' => .add,
        '*' => .multiply,
        else => error.InvalidCharacter,
    };
}

pub fn parseOperations(gpa: std.mem.Allocator, line: []const u8) !std.ArrayList(Operation) {
    var operations: std.ArrayList(Operation) = .empty;
    for (line) |char| {
        if (char == ' ') continue;
        try operations.append(gpa, try parseOperation(char));
    }
    return operations;
}

test "testParseRow" {
    var row = try parseRow(std.testing.allocator, "69    420 1");
    defer row.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices(u64, &[_]u64{ 69, 420, 1 }, row.items);
}

test "testParseOperations" {
    var row = try parseOperations(std.testing.allocator, "+    * *");
    defer row.deinit(std.testing.allocator);
    try std.testing.expectEqualSlices(Operation, &[_]Operation{ .add, .multiply, .multiply }, row.items);
}

test "testExample" {
    const lines = [_][]const u8{
        "123 328  51  64",
        " 45  64 387  23",
        "  6  98 215 314",
        "*   +   *   +",
    };

    try std.testing.expectEqual(4277556, try part_01(&lines));
}
