{
  buildGleamApplication,
  erlang,
  rebar3,
  src,
}:
buildGleamApplication {
  pname = "demo_web";
  version = "0";
  target = "erlang";
  erlangPackage = erlang;
  rebar3Package = rebar3;
  inherit src;
  localPackages = [ ./packages/inertia ];
}
