-module(erlav_encode_test).

-include_lib("eunit/include/eunit.hrl").

primitive_types_test() ->
    {ok, SchemaJSON} = file:read_file("priv/tschema2.avsc"),
    Encoder = avro:make_simple_encoder(SchemaJSON, []),
    Term = #{
        <<"intField">> => 789,
        <<"longField">> => 2989898111,
        <<"doubleField">> => 11.2345,
        <<"floatField">> => 23.12,
        <<"boolField">> => true,
        <<"stringField">> => <<"asdadasdasdasd3453534dfgdgd123456789">>
    },
    R1 = iolist_to_binary(Encoder(Term)),
    io:format("R1: ~p ~n", [R1]),
    SchemaId = erlav_nif:create_encoder(<<"priv/tschema2.avsc">>),
    Ret = erlav_nif:do_encode(SchemaId, Term),
    io:format("c++ ret: ~p ~n", [Ret]),
    ?assertEqual(R1, Ret).

create_encoder_test() ->
    Ret = erlav_nif:create_encoder(<<"priv/tschema2.avsc">>),
    io:format("CET1 ret: ~p ~n", [Ret]),
    Ret1 = erlav_nif:create_encoder(<<"priv/tschema2.avsc">>),
    io:format("CET2 ret: ~p ~n", [Ret]),
    ?assertEqual(Ret, Ret1),
    ok.
