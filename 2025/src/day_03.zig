const std = @import("std");

pub fn part_01(lines: []const []const u8) !u64 {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    var sum: u64 = 0;
    for (lines) |line| {
        var batteries: std.ArrayList(u8) = .empty;
        defer _ = batteries.deinit(gpa.allocator());

        for (line) |char| {
            const digit = try std.fmt.charToDigit(char, 10);
            try batteries.append(gpa.allocator(), digit);
        }

        sum += maxJoltage(batteries.items);
    }
    return sum;
}

fn maxJoltage(batteries: []const u8) u8 {
    var max = batteries[0] * 10 + batteries[1];
    var i: usize = 0;
    while (i < batteries.len) {
        var j: usize = i + 1;
        while (j < batteries.len) {
            const new_max = batteries[i] * 10 + batteries[j];
            if (new_max > max) {
                max = new_max;
            }
            j += 1;
        }
        i += 1;
    }
    return max;
}

test "testJoltage" {
    try std.testing.expectEqual(98, maxJoltage(&[_]u8{ 9, 8, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1 }));
    try std.testing.expectEqual(89, maxJoltage(&[_]u8{ 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9 }));
    try std.testing.expectEqual(78, maxJoltage(&[_]u8{ 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8 }));
    try std.testing.expectEqual(92, maxJoltage(&[_]u8{ 8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1 }));
}
