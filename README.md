



# forge init directory

```shell
forge init solidity-ex --no-commit --force
```



## build

```
cd solidity-ex
forge build


```

修改引入库的映射关系

代码引入openzeppelin

```solidity
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```



shell 安装相关依赖库

```shell
forge install OpenZeppelin/openzepplin-contracts --no-commit
```



如果执行不太顺利

```shell
cd lib/
git clone git@github.com:OpenZeppelin/openzeppelin-contracts.git
forge remappings 

@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
forge-std/=lib/forge-std/src/
openzeppelin-contracts/=lib/openzeppelin-contracts/
```

