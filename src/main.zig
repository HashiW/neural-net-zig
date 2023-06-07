const std = @import("std");

const Matrix = @import("matrix.zig").Matrix;
pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const mtr = try Matrix.random(3, 2, 16, &allocator);
    std.debug.print("{any}\n", .{mtr});

    const mtr2 = try Matrix.random(3, 2, 23, &allocator);
    std.debug.print("{any}\n", .{mtr2});

    const mtr3 = Matrix.transpose(mtr, &allocator);

    // const z = Matrix.random(3, 3);

    // const matrix3 = mtr.add(mtr2) catch unreachable;
    std.debug.print("{any}", .{mtr3});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
