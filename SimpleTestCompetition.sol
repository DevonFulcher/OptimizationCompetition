import "/OptimzationCompetition.sol";

contract SimpleTestCompetition is OptimizationCompetition(500, true) {
    /**
     * This is an incredibly simple example of an optimization problem
     */
    function objectiveFunction(int[] parameters) private pure returns(int y) {
        require(parameters.length == 1);
        //y = (x - 1)^2
        //optimum: x = 1
        return (parameters[0] - 1) * (parameters[0] - 1);
    }

    /*
    nonnegativity constraint
    */
    function constraints(int[] parameters) private pure returns(bool) {
    	if (parameters[0] < 0) {
    		return false;
    	} else {
    		return true;
    	}
    }
}