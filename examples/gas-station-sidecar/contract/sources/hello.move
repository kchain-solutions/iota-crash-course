module hello_world::hello {
    use std::string::{Self, String};

    /// Object published on-chain with a "Hello World" message.
    public struct HelloObject has key, store {
        id: UID,
        message: String,
    }

    /// Create a new shared HelloObject visible to everyone on-chain.
    public fun create(ctx: &mut TxContext) {
        transfer::public_share_object(
            HelloObject {
                id: object::new(ctx),
                message: string::utf8(b"Hello World"),
            },
        );
    }
}
