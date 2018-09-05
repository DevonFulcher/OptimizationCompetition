pragma solidity ^0.4.24;

/**
 * OptimizationCompetition crowd-sources the solving of optimization problems
 * via the Ethereum blockchain
 */
contract OptimizationCompetition {
    address private optimumSolutionAddress;
    int private optimumSolution;
    int[] private optimumParameters;
    //how much wei the winner of this competition will receive 
    uint private _bounty;
    uint private _competitionEnd;
    //if true the solution that minimizes the objective function will win the 
    //competition otherwise the solution that maximizes the objecive function
    //will win the competition.
    bool private _minimizeObjective;
    function objectiveFunction(int[] parameters) private pure returns(int y);
    function constraints(int[] parameters) private pure returns(bool);
    event CompetitionEnded(int optimumSolution, int[] optimumParameters);
    event NewOptimum(int optimumSolution, int[] optimumParameters);
    
    /**
     * create a new OptimizationCompetition
     * @param competitionTime The number of seconds after right now that this 
     *      competition will last.
     * @param minimizeObjective if true the solution that minimizes the 
     *      objective function will win the competition otherwise the solution that
     *      maximizes the objecive functionwill win the competition.
    */
    constructor(uint competitionTime, bool minimizeObjective) public payable{
        _competitionEnd = now + competitionTime;
        _minimizeObjective = minimizeObjective;
        if (_minimizeObjective) {
            optimumSolution = int256(~((uint256(1) << 255)));//int256 maximum value
        } else {
            optimumSolution = int256((uint256(1) << 255));//int256 minimum value
        }
        _bounty = msg.value;
    }
    
    /**
     * If parameters resolve objectiveFunction to be a better optimum than the
     * current optimum then the current optimum is replaced.
     * @param parameters The parameters to be evaluated on the objectiveFunction
     */
    function runCandidateSolution(int[] parameters) public {
        require(now < _competitionEnd);
        if (constraints(int[] parameters)) {
            int candidateSolution = objectiveFunction(parameters);
            bool newOptimum = false;
            if (_minimizeObjective) {
                if (candidateSolution < optimumSolution) {
                    newOptimum = true;
                }
            } else {
                if (candidateSolution > optimumSolution) {
                    newOptimum = true;
                }
            }
            if (newOptimum) {
                optimumSolution = candidateSolution;
                optimumSolutionAddress = msg.sender;
                optimumParameters = parameters;
                emit NewOptimum(optimumSolution, optimumParameters);
            }
        } else {
            revert("constraints not satisfied");
        }
    }
    
    /**
     * The winner of the competition can call this method to collect their
     * bounty when the competition is over
     */
    function claimBounty() public {
        if (now >= _competitionEnd && msg.sender == optimumSolutionAddress) {
            emit CompetitionEnded(optimumSolution, optimumParameters);
            selfdestruct(msg.sender);
        }
    }
}
