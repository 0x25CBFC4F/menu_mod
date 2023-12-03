OR, XOR, AND = 1, 3, 4

---Performs bit operation
---@param a number
---@param b number
---@param oper number
---@return number
function BitOperation(a, b, oper)
   local r, m, s = 0, 2^31
   repeat
      s,a,b = a+b+m, a%m, b%m
      r,m = r + m*oper%(s-a-b), m/2
   until m < 1
   return r
end
