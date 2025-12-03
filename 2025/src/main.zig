const std = @import("std");
const advent_of_code = @import("advent_of_code");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    var day: u8 = 1;
    var part: u8 = 1;
    var input: ?[]const u8 = null;

    var args = try std.process.argsWithAllocator(gpa.allocator());

    if (!args.skip()) {
        // Sanity check
        unreachable;
    }

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            // TODO: Print help
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

    var lines: std.ArrayList([]const u8) = .empty;
    defer _ = lines.deinit(gpa.allocator());

    var split = std.mem.splitScalar(u8, some_input, '\n');
    while (split.next()) |line| {
        try lines.append(gpa.allocator(), line);
    }

    if (part == 0 or part > 2) {
        std.debug.print("expected part to be either 1 or 2, got {}\n", .{part});
        std.process.exit(2);
    }

    const result = switch ((day * 10) + part) {
        // TODO: change return type from `i32` to `u64`
        // 11 => try advent_of_code.day_01.part_01(lines),
        // 12 => try advent_of_code.day_01.part_02(lines),
        21 => try advent_of_code.day_02.part_01(lines),
        else => {
            std.debug.print("expected day to be in range 1..=24, got {}\n", .{day});
            std.process.exit(2);
        },
    };

    std.debug.print("{}\n", .{result});
}
