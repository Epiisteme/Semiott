pragma solidity ^0.7.0;


contract SequentialHashing {


    function verify(uint256 x,uint256 y) public view returns (bool){
      uint256 p = 1000000007;
        for (uint count = 0; count < 10^4; count += 1){
            y=modExp(y,2,p);
        }
        return x==y;
      }   
      
    function modExp(uint256 base, uint256 exp, uint256 mod) internal view returns (uint256 result)  {
      result = 1;
      for (uint count = 1; count <= exp; count *= 2) {
            if (exp & count != 0)
                  result = mulmod(result, base, mod);
            base = mulmod(base, base, mod);
        }
      return result;
      }
 
    function hash(uint256 x) public view returns (uint256 r){
        uint256 p = 1000000007;
        x=x%p;
        for (uint count1 = 0; count1 < 10^4; count1 ++){
            x=modExp(x,uint256((p+1)/4),p);
            
        }
        return x;
      }
    }
