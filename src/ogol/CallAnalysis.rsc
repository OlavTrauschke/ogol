module ogol::CallAnalysis

import ogol::Syntax;
import ParseTree;
import Relation;

alias Fun = str;
alias Calls = rel[Fun, Fun];
alias Funs = set[Fun];

Calls getCallGraph(Program p) {
	calls = {};
	for(cmd <- p.cmds) {
		calls = calls + getCallsFromCommand(cmd,"global");
	}
	for (/FunDef f := p) {
		calls = calls + getCallsFromFunction(f);
	}
	return calls;
}

Calls getCallsFromFunction(FunDef f) {
	calls = {};
	
	for (cmd <- f.cmds) {
		calls = calls + getCallsFromCommand(cmd,"<f.id>");
	}
	return calls;
}

//Command ifelse
Calls getCallsFromCommand((Command) `ifelse <Expr e> <Block b1> <Block b2>`,Fun fId) {
	return getCallsFromBlock(b1,fId) + getCallsFromBlock(b2,fId);
}

//Command repeat
Calls getCallsFromCommand((Command) `repeat <Expr e> <Block b>`,Fun fId) {
	return getCallsFromBlock(b,fId);
}

//Command funCall
Calls getCallsFromCommand((Command) `<FunId calledFun> <Expr* e>;`,Fun callingFun) {
	return {<"<callingFun>","<calledFun>">};
}

//Block
Calls getCallsFromBlock((Block) `[<Command* cmds>]`,Fun fId) {
	calls = {};
	for (cmd <- cmds) {
		calls = calls + getCallsFromCommand(cmd,fId);
	}
	return calls;
}

default Calls getCallsFromCommand(Command cmd,Fun fId) {
	return {};
}

Calls getTransCallGraph(Program p)
	= getCallGraph(p)+;

Funs getReachableFunctions(Fun origin, Program p)
	= getTransCallGraph(p)[origin];
	
Funs getFunctionNames(Program p) {
	funs = {};
	for (/FunDef f := p) {
		funs = funs + "<f.id>";
	}
	return funs;
}

Funs getUnusedFunctions(Program p)
	= getFunctionNames(p) - getTransCallGraph(p)["global"];