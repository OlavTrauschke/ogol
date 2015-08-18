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
			   | home: "home"
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

keyword Reserved = "if" | "ifelse" | "while" | "repeat" | "forward" | "back"
				 | "right" | "left" | "pendown" | "penup" | "to" | "true" | "false" | "end";


lexical VarId
  = ":" [a-zA-Z][a-zA-Z0-9]* \ Reserved !>> [a-zA-Z0-9];
  
lexical FunId
  = [a-zA-Z][a-zA-Z0-9]* \ Reserved !>> [a-zA-Z0-9];

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

bool testParse(str txt) {
	try return !/amb(_) := parse(#Expr,txt);
	catch: return false;
}

public test bool n1() = testParse("1");
public test bool n2() = testParse("1234567");
public test bool n3() = testParse("-1234567");
public test bool n4() = testParse("-.1234567");
public test bool n5() = testParse("-123534.1234567");
public test bool f1() = !testParse("-123534.");
public test bool f2() = !testParse("-");
public test bool f3() = !testParse("-.");
public test bool t1() = testParse("1+1");
public test bool t2() = testParse("1+2+3");
public test bool t3() = testParse("1+1*2");
public test bool t4() = testParse("1+2*3/2");
public test bool t5() = testParse("1\<1");
public test bool t6() = testParse("1\>2");
public test bool t7() = testParse("1\<=2");
public test bool t8() = testParse("1\>=2");
public test bool t9() = testParse("1=2");
public test bool t10() = testParse("1!=2");
public test bool t11() = testParse("1+1*2\<1*2+3");
public test bool t12() = testParse("1+2\<2+3&&3+4\<=4+5");
public test bool t13() = testParse("false&&true");

public void render() {
	render(visParsetree(parse(#Expr,"1+2*3/2")));
}