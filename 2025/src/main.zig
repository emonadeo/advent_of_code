const std = @import("std");
const day_01 = @import("./day_01.zig");
const day_02 = @import("./day_02.zig");

pub fn main() !void {
    const inputs = try std.fs.cwd().openDir("../inputs/2025", .{});

    var file = try inputs.openFile("day_02.txt", .{ .mode = .read_only });
    defer file.close();

    var buffer: [1]u8 = undefined;
    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();

    var lines: std.ArrayList([]const u8) = .empty;

    var line = std.io.Writer.Allocating.init(alloc);
    defer line.deinit();

    while (true) {
        _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
            if (err == error.EndOfStream) break else return err;
        };
        // Skip newline (\n)
        _ = reader.toss(1);
        try lines.append(alloc, try line.toOwnedSlice());
        // Reset accumulating buffer
        line.clearRetainingCapacity();
    }

    // std.debug.print("day 01 :: part 1 :: {}\n", .{try day_01.part_01(lines)});
    // std.debug.print("day 01 :: part 2 :: {}\n", .{try day_01.part_02(lines)});
    std.debug.print("day 02 :: part 1 :: {}\n", .{try day_02.part_01(lines)});
}
