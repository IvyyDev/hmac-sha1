--!strict

local HttpService = game:GetService("HttpService")
local bit = bit32

local bor   = bit.bor
local band  = bit.band
local bxor  = bit.bxor
local bnot  = bit.bnot
local rol   = bit.lrotate
local floor = math.floor

local function toBytes(str: string): { number }
	local out = {}
	for i = 1, #str do
		out[i] = string.byte(str, i)
	end
	return out
end

function sha1(str: string): string
	local key = (game.JobId ~= "" and game.JobId) or HttpService:GenerateGUID(false)
	local blockSize = 64

	if #key > blockSize then
		key = tostring(sha1(key))
	end

	local keyBytes = toBytes(key)
	while #keyBytes < blockSize do
		table.insert(keyBytes, 0x00)
	end

	local o_key, i_key = {}, {}
	for i = 1, blockSize do
		local kb = keyBytes[i]
		o_key[i] = bxor(kb, 0x5c)
		i_key[i] = bxor(kb, 0x36)
	end

	local innerBytes = toBytes(string.char(table.unpack(i_key)) .. str)

	local function runSha1Round(dataBytes: { number }): string
		local h0,h1,h2,h3,h4 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0

		local bitLen = #dataBytes * 8
		table.insert(dataBytes, 0x80)
		while ((#dataBytes + 8) % 64) ~= 0 do
			table.insert(dataBytes, 0x00)
		end

		for i = 7, 0, -1 do
			table.insert(dataBytes, band(floor(bitLen / (2^(i*8))), 0xFF))
		end

		for i = 1, #dataBytes, 64 do
			local w = {}
			for j = 0, 15 do
				local a = dataBytes[i + j*4]
				local b = dataBytes[i + j*4 + 1]
				local c = dataBytes[i + j*4 + 2]
				local d = dataBytes[i + j*4 + 3]
				w[j] = bor(bor(a*2^24,b*2^16), bor(c*2^8,d))
			end

			for j = 16, 79 do
				w[j] = rol(bxor(bxor(w[j-3], w[j-8]), bxor(w[j-14], w[j-16])), 1)
			end

			local a,b,c,d,e = h0,h1,h2,h3,h4

			for j = 0, 79 do
				local f, k
				if j <= 19 then
					f = bor(band(b,c), band(bnot(b), d)); k = 0x5A827999
				elseif j <= 39 then
					f = bxor(b,c,d); k = 0x6ED9EBA1
				elseif j <= 59 then
					f = bor(bor(band(b,c), band(b,d)), band(c,d)); k = 0x8F1BBCDC
				else
					f = bxor(b,c,d); k = 0xCA62C1D6
				end

				local temp = (rol(a,5) + f + e + k + w[j]) % 2^32
				e = d; d = c; c = rol(b,30); b = a; a = temp
			end

			h0 = (h0 + a) % 2^32
			h1 = (h1 + b) % 2^32
			h2 = (h2 + c) % 2^32
			h3 = (h3 + d) % 2^32
			h4 = (h4 + e) % 2^32
		end

		return string.format("%08x%08x%08x%08x%08x", h0,h1,h2,h3,h4)
	end

	return runSha1Round(toBytes( string.char(table.unpack(o_key)) .. runSha1Round(innerBytes) ))
end

return sha1
