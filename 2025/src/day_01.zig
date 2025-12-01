const std = @import("std");

pub fn part_01(lines: std.ArrayList([]const u8)) !i32 {
    var password: i32 = 0;
    var dial: i32 = 50;
    for (lines.items) |line| {
        const direction = line[0];
        const amount = try std.fmt.parseInt(i32, line[1..], 10);
        dial = switch (direction) {
            'L' => @mod(dial - amount, 100),
            'R' => @mod(dial + amount, 100),
            else => unreachable,
        };
        if (dial == 0) {
            password += 1;
        }
    }
    return password;
}

pub fn part_02(lines: std.ArrayList([]const u8)) !i32 {
    var password: i32 = 0;
    var dial: i32 = 50;
    for (lines.items) |line| {
        const direction = line[0];
        const amount = try std.fmt.parseInt(i32, line[1..], 10);
        switch (direction) {
            'L' => {
                const next_dial = @mod(dial - amount, 100);
                if (next_dial > dial) {
                    password += 1;
                }
                password += @divTrunc(amount, 100);
                dial = next_dial;
            },
            'R' => {
                const next_dial = @mod(dial + amount, 100);
                if (next_dial < dial) {
                    password += 1;
                }
                password += @divTrunc(amount, 100);
                dial = next_dial;
            },
            else => unreachable,
        }
    }
    return password;
}

test part_01 {
    var lines_arr = [_][]const u8{ "L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82" };
    const lines = std.ArrayList([]const u8).fromOwnedSlice(&lines_arr);
    try std.testing.expectEqual(
        3,
        part_01(lines),
    );
}

test part_02 {
    var lines_arr = [_][]const u8{ "L68", "L30", "R48", "L5", "R60", "L55", "L1", "L99", "R14", "L82" };
    const lines = std.ArrayList([]const u8).fromOwnedSlice(&lines_arr);
    try std.testing.expectEqual(
        6,
        part_02(lines),
    );
}
