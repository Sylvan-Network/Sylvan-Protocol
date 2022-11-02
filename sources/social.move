module nfts::social_protocol {
    use std::ascii::{Self,String};
    use std::option::{Self,Option,some};
    use sui::object::{Self,UID};
    use sui::transfer;
    use sui::tx_context::{Self,TxContext};
    use std::vector::length;

    // Max text length
    const MAX_TEXT_LENGTH: u64 = 512;
    const ETextOverflow: u64 = 0;

    struct Chat has key,store {
        id: UID,
        app_id: address,
        text: string,
        // Set if referencing an another object (i.e., due to a Like, Retweet, Reply etc).
        // We allow referencing any object type, not ony Chat NFTs.
        ref_id: Option<address>,
        metadata:vector<u8>,
    }

    public fun text(char: &Chat):String {
        chat.text
    }

    fun post_internal(
        app_id: address,
        text: vector<u8>,
        ref_id:Option<address>,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    )  {
        assert!(length(&text) <= MAX_TEXT_LENGTH, ETextOverflow);
        let chat = Chat {
            id: object::new(ctx),
            app_id,
            text: ascii::string(text),
            ref_id,
            metadata,
        };
        transfer::transfer(chat, tx_context::sender(ctx));
    }

    /// Mint (post) a Chat object without referencing another object.
    public entry fun post(
        app_identifier: address,
        text: vector<u8>,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    ) {
        post_internal(app_identifier, text, option::none(), metadata, ctx);
    }

    /// Mint (post) a Chat object and reference another object (i.e., to simulate retweet, reply, like, attach).
    /// TODO: Using `address` as `app_identifier` & `ref_identifier` type, because we cannot pass `ID` to entry
    ///     functions. Using `vector<u8>` for `text` instead of `String`  for the same reason.
    public entry fun post_with_ref(
        app_identifier: address,
        text: vector<u8>,
        ref_identifier: address,
        metadata: vector<u8>,
        ctx: &mut TxContext,
    ) {
        post_internal(app_identifier, text, some(ref_identifier), metadata, ctx);
    }

    /// Burn a Chat object.
    public entry fun burn(chat: Chat) {
        let Chat { id, app_id: _, text: _, ref_id: _, metadata: _ } = chat;
        object::delete(id);
    }

}