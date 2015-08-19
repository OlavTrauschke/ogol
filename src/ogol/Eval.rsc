module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;

alias FunEnv = map[FunId id, FunDef def];

alias VarEnv = map[VarId id, Value val];

data Value
  = boolean(bool b)
  | number(real i)
  ;

/*
         +y
         |
         |
         |
-x ------+------- +x
         |
         |
         |
        -y

NB: home = (0, 0)
*/



alias Turtle = tuple[int dir, bool pendown, Point position];

alias State = tuple[Turtle turtle, Canvas canvas];

// Top-level eval function
Canvas eval(Program p);

FunEnv collectFunDefs(Program p);

State eval(Command cmd, FunEnv fenv, VarEnv venv, State state);

Value eval(Expr e, VarEnv venv);
