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
Canvas eval(p:(Program)`<Command* cmds>`){
	funenv = collectFunDefs(p);
	varenv = ();
	state = <<0, false, <0,0>>, []>;
	
	for(c <- cmds){
		state = eval(c, funenv, varEnv, state);
	}
	
	return state.canvas;
}

//  map[FunId id, FunDef def];
FunEnv collectFunDefs(Program p)
 = ( f.id: f | /FunDef f := p ); 

Program desugar(Program p){
 return visit (p){
 	case (Command)`fd <Expr e>;`
 		=>(Command) `forward <Expr e>;`
 	case (Command) `bk <Expr e>;`
 		=>(Command) `back <Expr e>;`
 	case (Command) `rt <Expr e>;`
 		=>(Command) `right <Expr e>;`
 	case (Command) `lt <Expr e>;`
 		=>(Command) `left <Expr e>;`
 	case (Command) `if <Expr c> <Block b>`
 		=>(Command)`ifelse <Expr c> <Block b> []`
 	case (Command) `pd;`
 		=>(Command) `pendown;`
 	case (Command) `pu;`
 		=>(Command) `penup;`
 	case (Expr) `<Expr lhs> \< <Expr rhs>`
 		=>(Expr) `<Expr rhs> \> <Expr lhs>`
	case (Expr) `<Expr lhs> \<= <Expr rhs>`
		=>(Expr) `<Expr rhs> \>= <Expr lhs>`
 }
}

//Block
State eval((Block) `[<Command* cmds>]`, FunEnv fenv, VarEnv venv, State state) {
	for(c <- cmds){
		state = eval(c, fenv, venv, state);
	}
	return state;
}

//Command if, ifelse
State eval((Command) `ifelse <Expr e> <Block b1> <Block b2>`,
			FunEnv fenv, VarEnv venv, State state) {
	boolean(c) = eval(e,venv);
	if (c) {
		return eval(b1,fenv,venv,state);
	}
	else {
		return eval(b2,fenv,venv,state);
	}
}

//Command repeat
State eval((Command) `repeat <Expr e> <Block b>`,
			FunEnv fenv, VarEnv venv, State state) {
	for(i <- [0..eval(e,venv).i]) {
		state = eval(b,fenv,venv,state);
	}
	return state;
}

//Command forward, fd

//Command back, bk

//Command home

//Command right, rt

//Command left, lt

//Command pendown, pd

//Command penup, pu

//Command fundef

//Command funcall

//Expr var
Value eval((Expr)`<VarId x>`, VarEnv env)
    = env[x];
    
test bool testVar()
 = eval((Expr)`:x`, ((VarId)`:x`: number(1.0)))
 ==number(1.0);
 
//Expr Number
Value eval((Expr) `<Number n>`, VarEnv env)
  = number(toReal(unparse(n)));/*number*/
  
test bool testNumber()
   = eval((Expr) `-1.23`, ())
   == number(-1.23);
   
//Expr Boolean true
Value eval((Expr) `true`, VarEnv env)
 = boolean(true); 

//Expr Boolean false
Value eval((Expr) `false`, VarEnv env)
 = boolean(false); 
 
test bool testTrue() = eval((Expr)`true`, ()) == boolean(true);

//Expr div
Value eval((Expr) `<Expr lhs> / <Expr rhs>`, VarEnv env)
	= number(x / y)
	when
		number(x) := eval(lhs, env),
		number(y) := eval(rhs, env);

test bool testDiv()
	= eval((Expr)`:x/2`, ((VarId)`:x`: number(11.5)))
	== number(5.75);

//Expr mul
Value eval((Expr)`<Expr lhs> * <Expr rhs>`, VarEnv env)
	= number(x * y)
	when
	  number(x) := eval(lhs, env),
	  number(y) := eval(rhs, env);

test bool testMul()
	= eval((Expr)`:x*2`, ((VarId)`:x`: number(2.0)))
	== number(4.0);

//Expr add
Value eval((Expr)`<Expr lhs> + <Expr rhs>`, VarEnv env)
	= number(x + y)
	when
	number(x) := eval(lhs, env),
	number(y) := eval(rhs, env);

test bool testAdd()
	= eval((Expr)`:x+2.33`, ((VarId)`:x`: number(2.66)))
	== number(4.99);

//Expr min
Value eval((Expr)`<Expr lhs> - <Expr rhs>`, VarEnv env)
	= number(x - y)
	when
	number(x) := eval(lhs, env),
	number(y) := eval(rhs, env);

test bool testMin()
	= eval((Expr)`:x-3`, ((VarId)`:x`: number(7.0)))
	== number(4.0);

//Expr gt
Value eval((Expr)`<Expr lhs> \> <Expr rhs>`, VarEnv env)
	= boolean(x > y)
	when
	number(x) := eval(lhs, env),
	number(y) := eval(rhs, env);
	
test bool testGt()
	= eval((Expr)`:x\>5`, ((VarId)`:x`: number(7.0)))
	== boolean(true);

//Expr gteq
Value eval((Expr) `<Expr lhs> \>= <Expr rhs>`, VarEnv env)
	= boolean(x >= y)
	when
	number(x) := eval(lhs, env),
	number(y) := eval(rhs, env);

test bool testGteq()
	=eval((Expr)`:x\>=5`, ((VarId)`:x`: number(5.5)))
	== boolean(true);
test bool testNGteq()
	=eval((Expr)`:x\>=5.5`, ((VarId)`:x`: number(5.0)))
	== boolean(false);

//Expr eq
Value eval((Expr) `<Expr lhs> = <Expr rhs>`, VarEnv env)
	= boolean(x == y)
	when
	x := eval(lhs, env),
	y := eval(rhs, env);

test bool testEq()
	=eval((Expr)`:x=5.0`, ((VarId)`:x`: number(5.0)))
	== boolean(true);
test bool testNEq()
	=eval((Expr)`:x=5.0`, ((VarId)`:x`: number(5.5)))
	== boolean(false);

//Expr neq
Value eval((Expr) `<Expr lhs> != <Expr rhs>`, VarEnv env)
	= boolean(x != y)
	when
	x := eval(lhs, env),
	y := eval(rhs, env);

test bool testNeq()
	=eval((Expr)`:x!=5.0`, ((VarId)`:x`: number(5.5)))
	== boolean(true);
test bool testNNeq()
	=eval((Expr)`:x!=5.0`, ((VarId)`:x`: number(5.0)))
	== boolean(false);

//Expr and
Value eval((Expr) `<Expr lhs> && <Expr rhs>`, VarEnv env)
	= boolean(x && y)
	when
	boolean(x) := eval(lhs, env),
	boolean(y) := eval(rhs, env);

test bool testAnd()
	=eval((Expr)`:x&&true`, ((VarId)`:x`: boolean(true)))
	== boolean(true);
test bool testNAnd()
	=eval((Expr)`:x&&true`, ((VarId)`:x`: boolean(false)))
	== boolean(false);

//Expr or
Value eval((Expr) `<Expr lhs> || <Expr rhs>`, VarEnv env)
	= boolean(x || y)
	when
	boolean(x) := eval(lhs, env),
	boolean(y) := eval(rhs, env);
test bool testOr()
	=eval((Expr)`:x||false`, ((VarId)`:x`: boolean(true)))
	== boolean(true);
test bool testNOr()
	=eval((Expr)`:x||false`, ((VarId)`:x`: boolean(false)))
	== boolean(false);

default Value eval(Expr e, VarEnv _){
	throw "Cannot eval: <e>"; 
}