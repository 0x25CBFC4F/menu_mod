
---Adds vector to current vector.
---@param self Vector4
---@param another Vector4
---@return Vector4
function AddVectors(self, another)
    return ToVector4({
        x = self.x + another.x,
        y = self.y + another.y,
        z = self.z + another.z,
        w = 1
    });
end

---Negates current vector
---@param self Vector4
---@return Vector4
function NegateVector(self)
    return ToVector4({
        x = -self.x,
        y = -self.y,
        z = -self.z,
        w = 1
    });
end

---Checks if vector is empty
---@param self Vector4
---@return boolean
function IsVectorEmpty(self)
    return self.x == 0 and
           self.y == 0 and
           self.z == 0;
end