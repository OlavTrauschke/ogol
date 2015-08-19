module ogol::Eval

import ogol::Syntax;
import ogol::Canvas;
import String;
import ParseTree;

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
Canvas eval((Program)`<Command* cmds>`){
	funenv = collectFunDefs(p);
	varenv = ();
	state = <<0, false, <0,0>>, []>;
	
	for(c <- cmds){
		state = evalCommand(c, funenv, varEnv, state);
	}
	
	return state.canvas;
}

//  map[FunId id, FunDef def];
FunEnv collectFunDefs(Program p)
 = ( f.id: f | /FunDef f= p );
 
// /d:(Command)`to <FunId f> <VarId* _> <Command _> end` := p); 

Program desugar(Program p){
 return visit (p){
 	case (Command)`fd <Expr e>;`
 		=>(Command) `forward <Expr e>;`
 		
 	case (Command)`if <Expr c> <Block b>`
 		=> (Command)`ifelse <Expr c> <Block b> []`
 }
}

State eval(Command cmd, FunEnv fenv, VarEnv venv, State state){}

Value eval(Expr e, VarEnv venv){}

Value eval((Expr) `true`, VarEnv env)
 = boolean(true);
 
test bool testTrue() = eval((Expr)`true`, ()) == boolean(true);
 
 Value eval((Expr) `<Number n>`, VarEnv env)
  = number(toReal(unparse(n)));
  
test bool testNumber()
   = eval((Expr) `-1.23`, ())
   == number(-1.23);
   
Value eval((Expr)`<VarId x>`, VarEnv env)
    = env[x];
    
test bool testVar()
 = eval((Expr)`:x`, ((VarId)`:x`: number(1.0)))
 ==number(1.0);

Value eval((Expr)`<Expr lhs> * <Expr rhs>`, VarEnv env)
	= number(x * y)
	when
	  number(x) := eval(lhs, env),
	  number(y) := eval(rhs, env);
	  
default Value eval(Expr e, VarEnv _){
	throw "Cannot eval: <e>"; 
}
	
test bool testMul2()
	= eval((Expr)`:x*2`, ((VarId)`:x`: number(2.0)))
	== number(4.0);module ogol::Eval

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
