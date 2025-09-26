module audit_trails::app {

    use std::string::String;
    use iota::clock::{Self, Clock};
    use iota::event;

    use audit_trails::nft_reward::send_nft_reward;


    public struct Product has key, store {
        id: UID,
        name: String,
        serial_number: String,
        manufacturer: String,
        image_url: String,
        timestamp: u64
    }

    public struct ProductEntry has key, store {
        id: UID,
        issuer_addr: address,
        entry_data: String,
        timestamp: u64
    }

    public struct ProductEntryLogged has drop, store, copy {
        product_addr: address,
        entry_addr: Option<address>
    }

    public entry fun new_product(
        name: String,
        manufacturer: String,
        serial_number: String,
        image_url: String,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let p_id = object::new(ctx);
        let p_addr = object::uid_to_address(&p_id);

        transfer::share_object(Product {
            id: p_id,
            name,
            serial_number,
            manufacturer,
            image_url,
            timestamp: clock::timestamp_ms(clock)
        });

        event::emit(
            ProductEntryLogged {
                product_addr: p_addr,
                entry_addr: option::none()
            }
        );
    }

    public entry fun log_entry_data(
        product: &Product,
        entry_data: String,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let product_id = object::id<Product>(product);
        let product_addr = object::id_to_address(&product_id);

        let e_id = object::new(ctx);
        let e_addr = object::uid_to_address(&e_id);

        transfer::transfer(ProductEntry {
            id: e_id,
            issuer_addr: tx_context::sender(ctx),
            entry_data,
            timestamp: clock::timestamp_ms(clock)
        }, product_addr);

        event::emit(ProductEntryLogged{
            product_addr,
            entry_addr: option::some<address>(e_addr),
        });

        // Always send NFT reward for logging an entry
        send_nft_reward(
            b"Product Entry Badge",
            b"Thanks for logging a product entry!",
            b"https://i.imgur.com/Jw7UvnH.png",
            tx_context::sender(ctx),
            ctx
        );
    }

}


