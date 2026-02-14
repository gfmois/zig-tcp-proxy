const std = @import("std");

pub const Server = struct {
    allocator: std.mem.Allocator,
    address: std.net.Address,
    listener: std.net.Server,

    pub fn init(allocator: std.mem.Allocator, port: u16) !Server {
        const addr = try std.net.Address.parseIp("127.0.0.1", port);
        const srv = try addr.listen(.{ .reuse_address = true });
        return .{ .allocator = allocator, .address = addr, .listener = srv };
    }

    pub fn deinit(self: *Server) void {
        self.listener.deinit();
    }

    pub fn run(self: *Server) !void {
        var rb: [64]u8 = undefined;
        const rs = try std.fmt.bufPrint(&rb, "{f}", .{self.address});
        std.debug.print("Listening on {s}\n", .{rs});
        while (true) {
            var conn = try self.listener.accept();
            defer conn.stream.close();

            std.debug.print("Client connected\n", .{});
            try handleClient(conn.stream);
        }
    }
};

fn handleClient(stream: std.net.Stream) !void {
    var buf: [4096]u8 = undefined;

    while (true) {
        const n = try stream.read(&buf);
        if (n == 0) {
            std.debug.print("User disconnected\n", .{});
            break;
        }
        std.debug.print("Read {d} bytes\n", .{n});
        try stream.writeAll(buf[0..n]);
    }
}
