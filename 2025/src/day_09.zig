const std = @import("std");

pub fn part_01(gpa: std.mem.Allocator, lines: []const []const u8) !u64 {
    var points: std.ArrayList(Point) = try .initCapacity(gpa, lines.len);
    defer points.deinit(gpa);
    for (lines) |line| {
        points.appendAssumeCapacity(try Point.parse(line));
    }

    const first_point = points.items[0];
    var largest_area: Area = .{ .a = first_point, .b = first_point };
    var largest_area_size: u64 = 0;
    for (points.items, 0..) |a, i| {
        for (points.items[(i + 1)..]) |b| {
            const new_area = Area{ .a = a, .b = b };
            const new_area_size = new_area.size();
            if (new_area_size > largest_area_size) {
                largest_area = new_area;
                largest_area_size = new_area_size;
            }
        }
    }

    return largest_area_size;
}

const Area = struct {
    a: Point,
    b: Point,

    const Self = @This();

    pub fn size(self: Self) u64 {
        return (@max(self.a.y, self.b.y) - @min(self.a.y, self.b.y) + 1) *
            (@max(self.a.x, self.b.x) - @min(self.a.x, self.b.x) + 1);
    }

    pub fn isInside(self: Self, point: Point) bool {
        return point.y >= @min(self.a.y, self.b.y) and
            point.y <= @max(self.a.y, self.b.y) and
            point.x >= @min(self.a.x, self.b.x) and
            point.x <= @max(self.a.x, self.b.x);
    }
};

const Point = struct {
    x: u64,
    y: u64,

    const Self = @This();

    pub fn parse(buf: []const u8) error{ Overflow, InvalidCharacter }!Self {
        var split = std.mem.splitScalar(u8, buf, ',');
        const x = try std.fmt.parseInt(u64, split.next() orelse return error.InvalidCharacter, 10);
        const y = try std.fmt.parseInt(u64, split.next() orelse return error.InvalidCharacter, 10);
        if (split.next() != null) return error.InvalidCharacter;
        return .{ .y = y, .x = x };
    }

    pub fn format(self: Self, writer: *std.io.Writer) std.io.Writer.Error!void {
        try writer.print("({}, {})", .{ self.x, self.y });
    }
};

test "testExample" {
    const points = [_]Point{
        .{ .x = 7, .y = 1 },
        .{ .x = 11, .y = 1 },
        .{ .x = 11, .y = 7 },
        .{ .x = 9, .y = 7 },
        .{ .x = 9, .y = 5 },
        .{ .x = 2, .y = 5 },
        .{ .x = 2, .y = 3 },
        .{ .x = 7, .y = 3 },
    };

    const first_point = points[0];
    var largest_area: Area = .{ .a = first_point, .b = first_point };
    var largest_area_size: u64 = 0;
    for (points) |a| {
        for (points) |b| {
            const new_area = Area{ .a = a, .b = b };
            const new_area_size = new_area.size();
            if (new_area_size > largest_area_size) {
                largest_area = new_area;
                largest_area_size = new_area_size;
            }
        }
    }

    try std.testing.expectEqual(50, largest_area_size);
}
