const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var server = std.http.Server.init(allocator, .{ .reuse_address = true });
    defer server.deinit();

    try server.listen(.{ .port = 8080, .address = .{ .any = {} } });
    std.log.info("Server running on http://0.0.0.0:8080", .{});

    while (true) {
        var res = try server.accept(.{ .allocator = allocator });
        defer res.deinit();

        try res.respond("{\"message\":\"hello world\"}", .{
            .status = .ok,
            .extra_headers = &.{
                .{ .name = "content-type", .value = "application/json" },
            },
        });
    }
}
