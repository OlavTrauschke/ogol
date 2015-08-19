module ogol::Syntax

import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;

/*

Ogol syntax summary

Program: Command...

Command:
 * Control flow: 
  if Expr Block
  ifelse Expr Block Block
  while Expr Block
  repeat Expr Block
 * Drawing (mind the closing semicolons)
  forward Expr; fd Expr; back Expr; bk Expr; home;
  right Expr; rt Expr; left Expr; lt Expr; 
  pendown; pd; penup; pu;
 * Procedures
  definition: to Name Var... Command... end
  call: Name Expr... ;
 
Block: [Command...]
 
Expressions
 * Variables :x, :y, :angle, etc.
 * Number: 1, 2, -3, 0.7, -.1, etc.
 * Boolean: true, false
 * Arithmetic: +, *, /, -
 * Comparison: >, <, >=, <=, =, !=
 * Logical: &&, ||

Reserved keywords
 if, ifelse, while, repeat, forward, back, right, left, pendown, 
 penup, to, true, false, end

Bonus:
 - add literal for colors
 - support setpencolor

*/

start syntax Program = Command*; 

syntax FunDef = "to" FunId VarId* Command* "end";
syntax FunCall = FunId Expr* ";";

syntax Expr = var: VarId
			| number: Number
			| boolean: Boolean
			| left (div: Expr "/" Expr
			| mul: Expr "*" Expr)
			> left (add: Expr "+" Expr
			| min: Expr "-" Expr)
			> gt: Expr "\>" Expr
			| lt: Expr "\<" Expr
			| gteq: Expr "\>=" Expr
			| lteq: Expr "\<=" Expr
			| eq: Expr "=" Expr
			| neq: Expr "!=" Expr
			> left (and: Expr "&&" Expr
			| or: Expr "||" Expr);

lexical Number = "-"?[0-9]+("."[0-9]+)?
			   | "-"?"."[0-9]+;

lexical Boolean = "true" | "false";

syntax Command = cond: "if" Expr Block
			   | cond2: "ifelse" Expr Block Block
			   | wLoop: "while" Expr Block
			   | rLoop: "repeat" Expr Block
			   | move: Move Expr ";"
			   | home: "home;"
			   | pen: PenAct ";"
			   | def: FunDef
			   | call: FunCall;

syntax Block = "[" Command* "]";

lexical Move = Forward | Back | Right | Left;
lexical Forward = "forward" | "fd";
lexical Back = "back" | "bk";
lexical Right = "right" | "rt";
lexical Left = "left" | "lt";

lexical PenAct = "pendown" | "pd" | "penup" | "pu";

keyword Reserved = "if" | "ifelse" | "while" | "repeat" | "forward" | "fd" | "back" | "bk"
				 | "right" | "rt" | "left" | "lt" | "pendown" | "pd" | "penup" | "pu" | "to"
				 | "true" | "false" | "end" | "home";


lexical VarId
  = ":" ([a-zA-Z][a-zA-Z0-9]*) \ Reserved !>> [a-zA-Z0-9];
  
lexical FunId
  = ([a-zA-Z][a-zA-Z0-9]*) \ Reserved !>> [a-zA-Z0-9];

layout Standard 
  = WhitespaceOrComment* !>> [\ \t\n\r] !>> "--";
  
lexical WhitespaceOrComment 
  = whitespace: Whitespace
  | comment: Comment
  ; 

lexical Whitespace
  = [\ \t\n\r]
  ;

lexical Comment
  = @category="Comment" "--" ![\n\r]* [\r][\n]
  ;

bool testExpr(str txt) {
	try return !/amb(_) := parse(#Expr,txt);
	catch: return false;
}

bool testCommand(str txt) {
	try return !/amb (_) := parse(#start[Program],txt);
	catch: return false;
}

bool testCommandLoc(loc txt) {
	try return !/amb (_) := parse(#start[Program],txt);
	catch: return false;
}

bool testFunDef(str txt) {
	try return !/amb (_) := parse(#FunDef,txt);
	catch: return false;
}

bool testFunCall(str txt) {
	try return !/amb (_) := parse(#FunCall,txt);
	catch: return false;
}

bool testBlock(str txt) {
	try return !/amb (_) := parse(#Block,txt);
	catch: return false;
}

public test bool n1() = testExpr("1");
public test bool n2() = testExpr("1234567");
public test bool n3() = testExpr("-1234567");
public test bool n4() = testExpr("-.1234567");
public test bool n5() = testExpr("-123534.1234567");
public test bool f1() = !testExpr("-123534.");
public test bool f2() = !testExpr("-");
public test bool f3() = !testExpr("-.");
public test bool t1() = testExpr("1+1");
public test bool t2() = testExpr("1+2+3");
public test bool t3() = testExpr("1+1*2");
public test bool t4() = testExpr("1+2*3/2");
public test bool t5() = testExpr("1\<1");
public test bool t6() = testExpr("1\>2");
public test bool t7() = testExpr("1\<=2");
public test bool t8() = testExpr("1\>=2");
public test bool t9() = testExpr("1=2");
public test bool t10() = testExpr("1!=2");
public test bool t11() = testExpr("1+1*2\<1*2+3");
public test bool t12() = testExpr("1+2\<2+3&&3+4\<=4+5");
public test bool t13() = testExpr("false&&true");
public test bool t14() = testFunDef("to f1 :p1 :p2 home; end");
public test bool t15() = testFunCall("f1 false&&true ;");
public test bool t16() = testCommand("home;");
public test bool t17() = testBlock("[home; home;]");
public test bool t18() = testCommand("pd;");
public test bool t19() = testCommand("if 1+2\<2+3&&3+4\<=4+5 [home; pd;]");
public test bool t20() = testCommand("if 1+2\<2+3&&3+4\<=4+5 [home; pd;] fd 5;");

public void renderExpr() {
	render1(#Expr,"1+2*3/2");
}

public void renderCommand() {
	render1(#Command,"home;");
}

public void renderFunDef() {
	render1(#FunDef,"to f1 :p1 :p2 home; end");
}

public void render1(t,str txt) {
	render(visParsetree(parse(t,"to f1 :p1 :p2 home; end")));
}

public bool render2(loc txt) {
	return testCommandLoc(txt);
}