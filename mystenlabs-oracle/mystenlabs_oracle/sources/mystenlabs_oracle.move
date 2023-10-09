// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A simple yet powerful core which allows creating new Capy
/// applications and give the power to mint once Capy Admin
/// authorized them via the common interface.
module mystenlabs_oracle::mystenlabs_oracle {
    use std::string::String;

    // Import the clock module for getting the current time.
    use sui::clock::Clock;
    // Import the dynamic_field module for adding custom fields to objects.
    use sui::dynamic_field as df;
    // Import the ed25519 module for verifying signatures.
    use sui::ed25519::ed25519_verify;
    // Import the event module for emitting events.
    use sui::event::emit;
    // Import the object module for creating and manipulating objects.
    use sui::object::{Self, UID};
    use sui::package;
    // Import the transfer module for sharing and transferring objects.
    use sui::transfer;
    // Import the tx_context module for accessing transaction information.
    use sui::tx_context::{sender, TxContext};

    /// Trying to perform an action when not authorized.
    const ENotAuthorized: u64 = 0;
    /// Does not comply to time limitation.
    const ENotTimeCompliant: u64 = 1;
    /// Error code for invalid signature.
    const EInvalidSignature: u64 = 2;

    // ======== Types =========

    /// Capability granting verify permission.
    struct AppCap has store, drop {
        app_name: String,
        time_limit: u64,
    }

    /// A struct that represents a verification token.
    /// This struct cannot be stored, owned or dropped by the user, it has to be used within the same transaction.
    struct Verification { }

    /// Admin Capability which allows third party applications to use the verify fn.
    struct AdminCap has key, store { id: UID }

    /// Custom key under which the app cap is attached.
    struct AppKey has copy, store, drop {}

    /// OTW to create the `Publisher`.
    struct MYSTENLABS_ORACLE has drop {}

    //------- Events ---------------

    struct VerifiedSuccessfully has copy, drop { sender: address }

    /// Module initializer. Uses One Time Witness to create Publisher and transfer it to sender
    fun init(otw: MYSTENLABS_ORACLE, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
        transfer::transfer(AdminCap { id: object::new(ctx) }, sender(ctx));
    }


    /// @param signature: 32-byte signature that is a point on the Ed25519 elliptic curve.
    /// @param public_key: 32-byte signature that is a point on the Ed25519 elliptic curve.
    /// @param msg: The message that we test the signature against.
    fun verify(
        signature: vector<u8>,
        public_key: vector<u8>,
        msg: vector<u8>
    ): bool {
        ed25519_verify(&signature, &public_key, &msg)
    }

    /// A public function that returns a Verification struct if the caller is verified by Mysten Labs.
    /// This function takes a mutable reference to the transaction context as a parameter, which can be used to check the caller's identity and other information.
    /// This function may abort with an error code if the caller is not authorized or if there is any other problem with the authorization process.
    public fun verify_dummy(
        signature: vector<u8>,
        public_key: vector<u8>,
        msg: vector<u8>,
        ctx: &mut TxContext
    ): Verification {
        let verified = verify(signature, public_key, msg);
        assert!(verified, EInvalidSignature);

        emit(
            VerifiedSuccessfully { sender: sender(ctx) }
        );

        Verification { }
    }
    
    /// A public function that returns an Authorization struct if the caller is authorized by Mysten Labs.
    /// Verification of a user can only be performed by an authorized application.
    public fun verify_authorized_app(
        app: &mut UID,
        clock: &Clock,
        signature: vector<u8>,
        public_key: vector<u8>,
        msg: vector<u8>,
        ctx: &mut TxContext
    ): Verification {
        assert!(is_authorized(app), ENotAuthorized);
        let app_cap = app_cap_mut(app);
        assert!((sui::clock::timestamp_ms(clock) <= app_cap.time_limit), ENotTimeCompliant);

        let verified = verify(signature, public_key, msg);
        assert!(verified, EInvalidSignature);

        emit(
            VerifiedSuccessfully { sender: sender(ctx) }
        );

        Verification { }
    }

    /// A public function that consumes a Verification struct.
    /// This function takes a Verification struct as a parameter, which can be obtained by calling the verify functions.
    public fun unpack(verification: Verification) {
        let Verification { } = verification;
        // TODO: implement the logic...
    }

    // === Authorization ===

    /// Attach an `AppCap` under an `AppKey` to grant an application access
    /// to minting and burning.
    public fun authorize_app(
        _: &AdminCap,
        app: &mut UID,
        app_name: String,
        time_limit: u64,
    ) {
        df::add(app, AppKey {},
            AppCap {
                app_name,
                time_limit
            }
        )
    }

    /// Detach the `AppCap` from the application to revoke access.
    public fun revoke_auth(
        _: &AdminCap, 
        app: &mut UID
    ) {
        let AppCap {
            app_name: _,
            time_limit: _,
        } = df::remove(app, AppKey {});
    }

    /// Check whether an Application has a permission to mint or
    /// burn a specific SuiFren<T>.
    public fun is_authorized(app: &UID): bool {
        df::exists_<AppKey>(app, AppKey {})
    }

    // === Internal ===

    /// Returns the `AppCap` that provides information about cohort.
    fun app_cap_mut(app: &mut UID): &mut AppCap {
        df::borrow_mut<AppKey, AppCap>(app, AppKey {})
    }

    // === Test functions ===

    #[test_only]
    public fun test_new_admin_cap(ctx: &mut TxContext): AdminCap {
        AdminCap { id: object::new(ctx) }
    }

    #[test_only]
    public fun test_destroy_admin_cap(cap: AdminCap) {
        let AdminCap { id } = cap;
        object::delete(id)
    }
}
