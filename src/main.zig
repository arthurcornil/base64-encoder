const std = @import("std");
const print = std.debug.print;

const Base64 = struct {
    table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            .table = upper ++ lower ++ numbers_symb
        };
    }

    pub fn encode(self: Base64, input: []const u8, allocator: std.mem.Allocator) ![]u8 {
        const output_len = ((input.len + 2) / 3) * 4;
        var output = try allocator.alloc(u8, output_len);
        var i: usize = 0;
        var j: usize = 0;

        while (i < input.len) : (i += 3) {
            const b0 = input[i];
            const b1 = if (i + 1 < input.len) input[i + 1] else 0;
            const b2 = if (i + 2 < input.len) input[i + 2] else 0;

            output[j] = self.table[b0 >> 2];
            output[j+1] = self.table[((b0 & 0x03) << 4) | (b1 >> 4)];
            output[j+2] = if (i + 1 < input.len) self.table[((b1 & 0x0F) << 2) | (b2 >> 6)] else '=';
            output[j+3] = if (i + 2 < input.len) self.table[b2 & 0x3F] else '=';
            j += 4;
        }
        return output;
    }
};

pub fn main() !void {
    const base64 = Base64.init();
    const input = "hel";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const output: []u8 = try base64.encode(input, allocator);
    defer allocator.free(output);

    print("{s}\n", .{output});
}
