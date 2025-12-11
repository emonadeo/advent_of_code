pub const day_01 = @import("./day_01.zig");
pub const day_02 = @import("./day_02.zig");
pub const day_03 = @import("./day_03.zig");
pub const day_04 = @import("./day_04.zig");
pub const day_05 = @import("./day_05.zig");
pub const day_06 = @import("./day_06.zig");
pub const day_07 = @import("./day_07.zig");
pub const day_08 = @import("./day_08.zig");

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}
