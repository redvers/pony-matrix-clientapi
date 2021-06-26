// in your code this `use` statement would be:
// use "matrixclient"
use "../../matrixclient"

actor Main
  new create(env: Env) =>
    env.out.print("we need at least 1 example. this one does nothing yet. want to contribute one?")
