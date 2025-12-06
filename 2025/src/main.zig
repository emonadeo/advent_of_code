const std = @import("std");

const advent_of_code = @import("advent_of_code");

pub fn main() !void {
    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    const gpa = debug_allocator.allocator();

    var day: u8 = 1;
    var part: u8 = 1;
    var is_file = false;
    var input: ?[]const u8 = null;

    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    if (!args.skip()) {
        // Sanity check
        unreachable;
    }

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            var buffer: [1024]u8 = undefined;
            var writer = std.fs.File.stdout().writerStreaming(&buffer);
            try printUsage(&writer.interface);
            std.process.exit(0);
        }
        if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--file")) {
            is_file = true;
        }
        if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--day")) {
            const next_arg = args.next() orelse {
                std.debug.print("expected argument after '{s}'\n", .{arg});
                std.process.exit(2);
            };
            day = try std.fmt.parseUnsigned(u8, next_arg, 10);
        }
        if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--part")) {
            const next_arg = args.next() orelse {
                std.debug.print("expected argument after '{s}'\n", .{arg});
                std.process.exit(2);
            };
            part = try std.fmt.parseUnsigned(u8, next_arg, 10);
        } else {
            input = arg;
        }
    }

    // I wish zig had shadowing :(
    const some_input = input orelse {
        std.debug.print("expected an input\n", .{});
        std.process.exit(2);
    };

    if (part == 0 or part > 2) {
        std.debug.print("expected part to be either 1 or 2, got {}\n", .{part});
        std.process.exit(2);
    }

    if (day == 0 or day > 24) {
        std.debug.print("expected day to be in range 1..=24, got {}\n", .{day});
        std.process.exit(2);
    }

    const lines = try parseInput(gpa, some_input, is_file);
    defer {
        for (lines) |line| gpa.free(line);
        gpa.free(lines);
    }

    const result = switch ((day * 10) + part) {
        // TODO: change return type from `i32` to `u64`
        // 11 => try advent_of_code.day_01.part_01(lines),
        // 12 => try advent_of_code.day_01.part_02(lines),
        21 => try advent_of_code.day_02.part_01(lines),
        31 => try advent_of_code.day_03.part_01(lines),
        41 => try advent_of_code.day_04.part_01(lines),
        else => unreachable,
    };

    std.debug.print("{}\n", .{result});
}

fn parseInput(gpa: std.mem.Allocator, input: []const u8, is_file: bool) ![]const []const u8 {
    var lines: std.ArrayList([]const u8) = .empty;

    if (is_file) {
        const file = try std.fs.cwd().openFile(input, .{ .mode = .read_only });
        defer file.close();

        var buffer: [1024]u8 = undefined;
        var file_reader = file.reader(&buffer);
        const reader = &file_reader.interface;

        var line = std.io.Writer.Allocating.init(gpa);
        defer line.deinit();

        // Option B:
        while (true) {
            _ = reader.streamDelimiter(&line.writer, '\n') catch |err| {
                if (err == error.EndOfStream) break else return err;
            };
            // Skip newline (\n)
            _ = reader.toss(1);
            try lines.append(gpa, try line.toOwnedSlice());
        }
    } else {
        var split = std.mem.splitScalar(u8, input, '\n');
        while (split.next()) |line| {
            try lines.append(gpa, line);
        }
    }

    return lines.toOwnedSlice(gpa);
}

fn printUsage(w: *std.io.Writer) !void {
    try w.writeAll(
        \\Usage: aoc [OPTIONS] <INPUT>
        \\
        \\Options:
        \\  -d, --day <NUMBER>   Day of the puzzle. Number between 1 and 24.
        \\  -p, --part <NUMBER>  Part of the puzzle. Must be either 1 or 2.
        \\  -f, --file           Read file contents at <INPUT> as input, instead of passing it in directly.
        \\  -h, --help           Print this message.
    );
    try w.flush();
}
