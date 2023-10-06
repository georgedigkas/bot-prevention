
module demo_app::interact {

    use mystenlabs_oracle::mystenlabs_oracle::Authorization;

    public fun interact(authorization: Authorization) {
        // TODO: implement the logic...
        mystenlabs_oracle::mystenlabs_oracle::unpack(authorization);
    }

}
