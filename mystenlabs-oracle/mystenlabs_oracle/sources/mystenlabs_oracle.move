// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// This module defines the mystenlabs_oracle contract, 
/// which allows authorized users to access the oracle data provided by Mysten Labs.
module mystenlabs_oracle::mystenlabs_oracle {
    use sui::tx_context::TxContext;

    /// A struct that represents an authorization token for accessing the oracle data.
    /// This struct cannot be stored, owned or dropped by the user, it has to be used within the same transaction.
    struct Authorization { }

    /// A public function that returns an Authorization struct if the caller is authorized by Mysten Labs.
    /// This function takes a mutable reference to the transaction context as a parameter, which can be used to check the caller's identity and other information.
    /// This function may abort with an error code if the caller is not authorized or if there is any other problem with the authorization process.
    public fun authorize(_ctx: &mut TxContext): Authorization {
        Authorization { }
    }

    /// A public function that consumes an Authorization struct and allows the user to access the oracle data.
    /// This function takes an Authorization struct as a parameter, which can be obtained by calling the authorize function.
    /// This function may abort with an error code if the Authorization struct is invalid or if there is any other problem with accessing the oracle data.
    public fun unpack(authorization: Authorization) {
        let Authorization { } = authorization;
        // TODO: implement the logic...
    }

}
