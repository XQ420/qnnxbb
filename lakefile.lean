import Lake
open Lake DSL

package «SyniLF» {

}
  -- add any package configuration options here

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"


@[default_target]
lean_lib «SyniLF» {

}
  -- add any library configuration options here
