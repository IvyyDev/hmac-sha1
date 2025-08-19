# ivy's luau sha1  
✨ tiny hmac‐sha1 util • job-based keying • no dependencies ✨

---

### 💡 quick taste

```lua
local sha1 = require(path.to.sha1)

print( sha1("hello world") )
-- → d2b5... (changes every job runtime because of HMAC)
```

---

### 🔧 how it works

this is a stripped sha1 implementation written specifically for luau and bit32.  
hmac is **always** applied with `game.JobId` as the key.  
if the place is running in studio and JobId is empty, a fresh GUID is used *per call*.

your output hashes are still sha1-compliant – they’re just keyed for extra entropy  
(which makes them safe for networking / security uses)

---

### ✅ features

- 🧠 **pure luau** – no ffi / external libs
- 🔁 **deterministic inside a single job**  
- 🔐 **randomised across jobs** (guid fallback)

---

### ⚠️ note

this does **not** support streaming / `update()` patterns.  
if you want incremental hashing → *use a different lib lol*.

---

### 🧩 api

| function     | description                                 |
|--------------|---------------------------------------------|
| `sha1(str)`  | returns a hmac-sha1 hex digest (`string`)   |
