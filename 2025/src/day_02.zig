const std = @import("std");

pub fn part_01(lines: std.ArrayList([]const u8)) !u64 {
    const first_line = lines.items[0];
    var ranges = std.mem.splitScalar(u8, first_line, ',');
    var sum: u64 = 0;
    while (ranges.next()) |range| {
        var range_split = std.mem.splitScalar(u8, range, '-');
        const min_str = range_split.next() orelse unreachable;
        const max_str = range_split.next() orelse unreachable;
        const min = try std.fmt.parseInt(u64, min_str, 10);
        const max = try std.fmt.parseInt(u64, max_str, 10);
        for (try invalidIds(.{ min, max })) |invalid_id| {
            sum += invalid_id;
        }
    }
    return sum;
}

const Range = struct { u64, u64 };

fn invalidIds(self: Range) ![]const u64 {
    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();
    var invalid_ids: std.ArrayList(u64) = .empty;

    const min, const max = self;

    // std.debug.print("min: {}, max: {}\n", .{ min, max });

    const digit_countt = countDigits(min);
    // std.debug.print("digit count of min: {}\n", .{digit_countt});

    var next_invalid_id = switch (@mod(digit_countt, 2)) {
        1 => std.math.pow(u64, 10, digit_countt) + std.math.pow(u64, 10, (digit_countt) / 2),
        0 => blk: {
            const half_digit_count = @divTrunc(digit_countt, 2);
            const half = @divTrunc(min, std.math.pow(u64, 10, half_digit_count));
            // std.debug.print("half: {}\n", .{half});
            var n = half * std.math.pow(u64, 10, half_digit_count) + half;
            if (n < min) {
                n += std.math.pow(u64, 10, half_digit_count) + 1;
            }
            break :blk n;
        },
        else => unreachable,
    };

    while (next_invalid_id <= max) {
        // std.debug.print("next id: {}\n", .{next_invalid_id});
        try invalid_ids.append(alloc, next_invalid_id);
        next_invalid_id = next_invalid_id + std.math.pow(u64, 10, @divTrunc(countDigits(next_invalid_id), 2)) + 1;

        // Skip numbers with uneven amount of digits.
        const digit_count = countDigits(next_invalid_id);
        if (@mod(digit_count, 2) == 1) {
            // std.debug.print("{} not valid, skip to next magnitude\n", .{next_invalid_id});
            next_invalid_id = std.math.pow(u64, 10, digit_count) + std.math.pow(u64, 10, @divTrunc(digit_count, 2));
        }
    }

    return invalid_ids.toOwnedSlice(alloc);
}

fn countDigits(x: anytype) @TypeOf(x) {
    if (x < 0) {
        return countDigits(-x);
    }
    if (x == 0) {
        return 1;
    }
    return std.math.log10(x) + 1;
}

test "countInvalidIds" {
    try std.testing.expectEqualSlices(u64, &[_]u64{ 11, 22 }, try invalidIds(.{ 11, 22 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{99}, try invalidIds(.{ 95, 115 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{1010}, try invalidIds(.{ 998, 1012 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{1188511885}, try invalidIds(.{ 1188511880, 1188511890 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{222222}, try invalidIds(.{ 222220, 222224 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{}, try invalidIds(.{ 1698522, 1698528 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{446446}, try invalidIds(.{ 446443, 446449 }));
    try std.testing.expectEqualSlices(u64, &[_]u64{38593859}, try invalidIds(.{ 38593856, 38593862 }));
}

// 11
// 22
// 33
// 44
// 55
// 66
// 77
// 88
// 99
// = 9
//
// 2 digits -> 9
//
// 1010
// 1111
// 1212
// 1313
// 1414
// ...
// 1919
// = 10
//
// 2020
// ...
// = 10
//
// 4 digits -> 90
//
// 100100
// 101101
// 102102
// ...
// 109109
// = 10
//
// 110110
// ...
// 119119
// = 10
//
// 6 digits -> 900
//
// formula: 9*10^(digit_count / 2 - 1)
