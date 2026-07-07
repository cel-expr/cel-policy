# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Defines a bazel rule for bundling CEL policy conformance tests."""

def _cel_policy_test_bundle_impl(ctx):
    inputs = []
    args = ctx.actions.args()
    if ctx.file.environment:
        inputs.append(ctx.file.environment)
        args.add("--environment", ctx.file.environment.path)
    if ctx.file.policy:
        inputs.append(ctx.file.policy)
        args.add("--policy", ctx.file.policy.path)
    if ctx.file.test:
        inputs.append(ctx.file.test)
        args.add("--test", ctx.file.test.path)

    args.add("--output", ctx.outputs.out.path)

    ctx.actions.run(
        inputs = inputs,
        outputs = [ctx.outputs.out],
        executable = ctx.executable._bundle_tool,
        arguments = [args],
        mnemonic = "CelPolicyBundle",
        progress_message = "Bundling CEL policy test %s" % ctx.label,
    )
    return [DefaultInfo(files = depset([ctx.outputs.out]))]

cel_policy_test_bundle = rule(
    doc = """Bundles CEL policy conformance tests into a single YAML file.

    Output file is a YAML file with three documents: environment, policy, and
    test.

    If there is no environment file, the environment document will be omitted.
    """,
    implementation = _cel_policy_test_bundle_impl,
    outputs = {"out": "%{name}_bundle.yaml"},
    attrs = {
        "environment": attr.label(allow_single_file = [".yaml"]),
        "policy": attr.label(allow_single_file = [".yaml"], mandatory = True),
        "test": attr.label(allow_single_file = [".yaml"], mandatory = True),
        "_bundle_tool": attr.label(
            default = "//bazel:bundle",
            executable = True,
            cfg = "exec",
        ),
    },
)
