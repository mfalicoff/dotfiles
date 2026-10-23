# Exercise the Invoke 3 API that unpatched Fabric cannot handle; no SSH needed.
{pkgs}: let
  python = pkgs.python3.withPackages (ps: [ps.fabric]);
in
  pkgs.runCommand "fabric-invoke-compatibility" {nativeBuildInputs = [python];} ''
    python - <<'PY'
    from types import SimpleNamespace
    from fabric import Config, task
    from fabric.tasks import ConnectionCall
    import invoke

    assert invoke.__version__.startswith("3.")

    @task
    def example(context):
        pass

    call = ConnectionCall(example, init_kwargs={"host": "localhost"})
    context = call.make_context(
        Config(), core_parse_result=SimpleNamespace(remainder="unparsed arguments")
    )
    assert context.host == "localhost"
    assert context.remainder == "unparsed arguments"
    PY
    touch $out
  ''
