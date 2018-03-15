
/* Unicorn Emulator Engine */
/* By Nguyen Anh Quynh <aquynh@gmail.com>, 2015-2017 */
/* This file is released under LGPL2.
   See COPYING.LGPL2 in root directory for more details
*/

import CUnicorn
public typealias Hook = Int
public typealias Engine = OpaquePointer
public typealias Context = OpaquePointer

public protocol Register {
    var value: Int32 { get }
}

/*
  Macro to create combined version which can be compared to
  result of uc_version() API.
*/

public struct Arch: Equatable {
    public var rawValue: uc_arch

    public static func ==(lhs: Arch, rhs: Arch) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    /// ARM architecture (including Thumb, Thumb-2)
    public static let arm = Arch(rawValue: UC_ARCH_ARM)

    /// ARM-64, also called AArch64
    public static let arm64 = Arch(rawValue: UC_ARCH_ARM64)

    /// Mips architecture
    public static let mips = Arch(rawValue: UC_ARCH_MIPS)

    /// X86 architecture (including x86 & x86-64)
    public static let x86 = Arch(rawValue: UC_ARCH_X86)

    // PowerPC architecture (currently unsupported)
    public static let ppc = Arch(rawValue: UC_ARCH_PPC)

    /// Sparc architecture
    public static let sparc = Arch(rawValue: UC_ARCH_SPARC)

    /// M68K architecture
    public static let m68k = Arch(rawValue: UC_ARCH_M68K)
}



// Mode type
public struct Mode: Equatable {
    public var rawValue: uc_mode

    public static func ==(lhs: Mode, rhs: Mode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func |(lhs: Mode, rhs: Mode) -> Mode {
        return Mode(rawValue: uc_mode(lhs.rawValue.rawValue | rhs.rawValue.rawValue))
    }

    /// little-endian mode (default mode)
    public static let littleEndian = Mode(rawValue: UC_MODE_LITTLE_ENDIAN)   
    /// big-endian mode
    public static let bigEndian = Mode(rawValue: UC_MODE_BIG_ENDIAN)

    // arm / arm64
    /// ARM mode
    public static let arm = Mode(rawValue: UC_MODE_ARM)             
    /// THUMB mode (including Thumb-2)
    public static let thumb = Mode(rawValue: UC_MODE_THUMB)      
    /// ARM's Cortex-M series (currently unsupported)
    public static let mclass = Mode(rawValue: UC_MODE_MCLASS)     
    /// ARMv8 A32 encodings for ARM (currently unsupported)
    public static let v8 = Mode(rawValue: UC_MODE_V8)         

    // mips
    /// MicroMips mode (currently unsupported)
    public static let micro = Mode(rawValue: UC_MODE_MICRO)      
    /// Mips III ISA (currently unsupported)
    public static let mips3 = Mode(rawValue: UC_MODE_MIPS3)      
    /// Mips32r6 ISA (currently unsupported)
    public static let mips32r6 = Mode(rawValue: UC_MODE_MIPS32R6)   
    /// Mips32 ISA
    public static let mips32 = Mode(rawValue: UC_MODE_MIPS32)     
    /// Mips64 ISA
    public static let mips64 = Mode(rawValue: UC_MODE_MIPS64)     

    // x86 / x64
    /// 16-bit mode
    public static let bits16 = Mode(rawValue: UC_MODE_16)         
    /// 32-bit mode
    public static let bits32 = Mode(rawValue: UC_MODE_32)         
    /// 64-bit mode
    public static let bits64 = Mode(rawValue: UC_MODE_64)         

    // ppc 
    /// 32-bit mode (currently unsupported)
    public static let ppc32 = Mode(rawValue: UC_MODE_PPC32)      
    /// 64-bit mode (currently unsupported)
    public static let ppc64 = Mode(rawValue: UC_MODE_PPC64)      
    /// Quad Processing eXtensions mode (currently unsupported)
    public static let qpx = Mode(rawValue: UC_MODE_QPX)        

    // sparc
    /// 32-bit mode
    public static let sparc32 = Mode(rawValue: UC_MODE_SPARC32)    
    /// 64-bit mode
    public static let sparc64 = Mode(rawValue: UC_MODE_SPARC64)    
    /// SparcV9 mode (currently unsupported)
    public static let v9 = Mode(rawValue: UC_MODE_V9)         
}

// All type of errors encountered by Unicorn API.
// These are values returned by uc_errno()
public struct UnicornError: Error, Equatable, CustomStringConvertible {
    public var rawValue: uc_err

    public static func ==(lhs: UnicornError, rhs: UnicornError) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public var description: String {
        return rawValue.rawValue.description + ": " + String(cString: uc_strerror(rawValue))
    }

    /// No error: everything was fine
    public static let ok = UnicornError(rawValue: UC_ERR_OK)  
    /// Out-Of-Memory error: uc_open(), uc_emulate()
    public static let nomem = UnicornError(rawValue: UC_ERR_NOMEM)     
    /// Unsupported architecture: uc_open()
    public static let arch = UnicornError(rawValue: UC_ERR_ARCH)    
    /// Invalid handle
    public static let handle = UnicornError(rawValue: UC_ERR_HANDLE)  
    /// Invalid/unsupported mode: uc_open()
    public static let mode = UnicornError(rawValue: UC_ERR_MODE)    
    /// Unsupported version (bindings)
    public static let version = UnicornError(rawValue: UC_ERR_VERSION) 
    /// Quit emulation due to READ on unmapped memory: uc_emu_start()
    public static let readUnmapped = UnicornError(rawValue: UC_ERR_READ_UNMAPPED)
    /// Quit emulation due to WRITE on unmapped memory: uc_emu_start()
    public static let writeUnmapped = UnicornError(rawValue: UC_ERR_WRITE_UNMAPPED)
    /// Quit emulation due to FETCH on unmapped memory: uc_emu_start()
    public static let fetchUnmapped = UnicornError(rawValue: UC_ERR_FETCH_UNMAPPED)
    /// Invalid hook type: uc_hook_add()
    public static let hook = UnicornError(rawValue: UC_ERR_HOOK)   
    /// Quit emulation due to invalid instruction: uc_emu_start()
    public static let insnInvalid = UnicornError(rawValue: UC_ERR_INSN_INVALID)
    /// Invalid memory mapping: uc_mem_map()
    public static let map = UnicornError(rawValue: UC_ERR_MAP)
    /// Quit emulation due to UC_MEM_WRITE_PROT violation: uc_emu_start()
    public static let writeProt = UnicornError(rawValue: UC_ERR_WRITE_PROT)
    /// Quit emulation due to UC_MEM_READ_PROT violation: uc_emu_start()
    public static let readProt = UnicornError(rawValue: UC_ERR_READ_PROT)
    /// Quit emulation due to UC_MEM_FETCH_PROT violation: uc_emu_start()
    public static let fetchProt = UnicornError(rawValue: UC_ERR_FETCH_PROT)
    /// Inavalid argument provided to uc_xxx function (See specific function API)
    public static let arg = UnicornError(rawValue: UC_ERR_ARG)    
    /// Unaligned read
    public static let readUnaligned = UnicornError(rawValue: UC_ERR_READ_UNALIGNED) 
    /// Unaligned write
    public static let writeUnaligned = UnicornError(rawValue: UC_ERR_WRITE_UNALIGNED) 
    /// Unaligned fetch
    public static let fetchUnaligned = UnicornError(rawValue: UC_ERR_FETCH_UNALIGNED) 
    /// hook for this event already existed
    public static let hookExist = UnicornError(rawValue: UC_ERR_HOOK_EXIST) 
    /// Insufficient resource: uc_emu_start()
    public static let resource = UnicornError(rawValue: UC_ERR_RESOURCE)   
    /// Unhandled CPU exception
    public static let exception = UnicornError(rawValue: UC_ERR_EXCEPTION)
}

/*
  Callback function for tracing code (UC_HOOK_CODE & UC_HOOK_BLOCK)

  @address: address where the code is being executed
  @size: size of machine instruction(s) being executed, or 0 when size is unknown
  @user_data: user data passed to tracing APIs.
*/
public typealias uc_cb_hookcode_t = @convention(c) (OpaquePointer?, UInt64, UInt32, UnsafeMutableRawPointer?) -> Swift.Void

/*
  Callback function for tracing interrupts (for uc_hook_intr())

  @intno: interrupt number
  @user_data: user data passed to tracing APIs.
*/
public typealias uc_cb_hookintr_t = @convention(c) (OpaquePointer?, UInt32, UnsafeMutableRawPointer?) -> Swift.Void

/*
  Callback function for tracing IN instruction of X86

  @port: port number
  @size: data size (1/2/4) to be read from this port
  @user_data: user data passed to tracing APIs.
*/
public typealias uc_cb_insn_in_t = @convention(c) (OpaquePointer?, UInt32, Int32, UnsafeMutableRawPointer?) -> UInt32

/*
  Callback function for OUT instruction of X86

  @port: port number
  @size: data size (1/2/4) to be written to this port
  @value: data value to be written to this port
*/
public typealias uc_cb_insn_out_t = @convention(c) (OpaquePointer?, UInt32, Int32, UInt32, UnsafeMutableRawPointer?) -> Swift.Void

// All type of memory accesses for UC_HOOK_MEM_*
public struct MemType: Equatable {
    public var rawValue: uc_mem_type

    public static func ==(lhs: MemType, rhs: MemType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    /// Memory is read from
    public static let read = MemType(rawValue: UC_MEM_READ)
    /// Memory is written to
    public static let write = MemType(rawValue: UC_MEM_WRITE)
    /// Memory is fetched
    public static let fetch = MemType(rawValue: UC_MEM_FETCH)
    /// Unmapped memory is read from
    public static let readUnmapped = MemType(rawValue: UC_MEM_READ_UNMAPPED)
    /// Unmapped memory is written to
    public static let writeUnmapped = MemType(rawValue: UC_MEM_WRITE_UNMAPPED)
    /// Unmapped memory is fetched
    public static let fetchUnmapped = MemType(rawValue: UC_MEM_FETCH_UNMAPPED)
    /// Write to write protected, but mapped, memory
    public static let writeProt = MemType(rawValue: UC_MEM_WRITE_PROT)
    /// Read from read protected, but mapped, memory
    public static let readProt = MemType(rawValue: UC_MEM_READ_PROT)
    /// Fetch from non-executable, but mapped, memory
    public static let fetchProt = MemType(rawValue: UC_MEM_FETCH_PROT)
    /// Memory is read from (successful access)
    public static let readAfter = MemType(rawValue: UC_MEM_READ_AFTER)
}

// All type of hooks for uc_hook_add() API.
public struct HookType: Equatable {
    public var rawValue: uc_hook_type

    public static func ==(lhs: HookType, rhs: HookType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    /// Hook all interrupt/syscall events
    public static let intr = HookType(rawValue: UC_HOOK_INTR)
    /// Hook a particular instruction - only a very small subset of instructions supported here
    public static let insn = HookType(rawValue: UC_HOOK_INSN)
    /// Hook a range of code
    public static let code = HookType(rawValue: UC_HOOK_CODE)
    /// Hook basic blocks
    public static let block = HookType(rawValue: UC_HOOK_BLOCK)
    /// Hook for memory read on unmapped memory
    public static let memReadUnmapped = HookType(rawValue: UC_HOOK_MEM_READ_UNMAPPED)
    /// Hook for invalid memory write events
    public static let memWriteUnmapped = HookType(rawValue: UC_HOOK_MEM_WRITE_UNMAPPED)
    /// Hook for invalid memory fetch for execution events
    public static let memFetchUnmapped = HookType(rawValue: UC_HOOK_MEM_FETCH_UNMAPPED)
    /// Hook for memory read on read-protected memory
    public static let memReadProt = HookType(rawValue: UC_HOOK_MEM_READ_PROT)
    /// Hook for memory write on write-protected memory
    public static let memWriteProt = HookType(rawValue: UC_HOOK_MEM_WRITE_PROT)
    /// Hook for memory fetch on non-executable memory
    public static let memFetchProt = HookType(rawValue: UC_HOOK_MEM_FETCH_PROT)
    /// Hook memory read events.
    public static let memRead = HookType(rawValue: UC_HOOK_MEM_READ)
    /// Hook memory write events.
    public static let memWrite = HookType(rawValue: UC_HOOK_MEM_WRITE)
    /// Hook memory fetch for execution events
    public static let memFetch = HookType(rawValue: UC_HOOK_MEM_FETCH)
    /// Hook memory read events, but only successful access.
    /// The callback will be triggered after successful read.
    public static let memReadAfter = HookType(rawValue: UC_HOOK_MEM_READ_AFTER)
}

/*
  Callback function for hooking memory (READ, WRITE & FETCH)

  @type: this memory is being READ, or WRITE
  @address: address where the code is being executed
  @size: size of data being read or written
  @value: value of data being written to memory, or irrelevant if type = READ.
  @user_data: user data passed to tracing APIs
*/
//public typealias uc_cb_hookmem_t = @convention(c) (OpaquePointer?, MemType, UInt64, Int32, Int64, UnsafeMutableRawPointer?) -> Swift.Void

/*
  Callback function for handling invalid memory access events (UNMAPPED and
    PROT events)

  @type: this memory is being READ, or WRITE
  @address: address where the code is being executed
  @size: size of data being read or written
  @value: value of data being written to memory, or irrelevant if type = READ.
  @user_data: user data passed to tracing APIs

  @return: return true to continue, or false to stop program (due to invalid memory).
           NOTE: returning true to continue execution will only work if if the accessed
           memory is made accessible with the correct permissions during the hook.

           In the event of a UC_MEM_READ_UNMAPPED or UC_MEM_WRITE_UNMAPPED callback,
           the memory should be uc_mem_map()-ed with the correct permissions, and the
           instruction will then read or write to the address as it was supposed to.

           In the event of a UC_MEM_FETCH_UNMAPPED callback, the memory can be mapped
           in as executable, in which case execution will resume from the fetched address.
           The instruction pointer may be written to in order to change where execution resumes,
           but the fetch must succeed if execution is to resume.
*/
//public typealias uc_cb_eventmem_t = @convention(c) (OpaquePointer?, MemType, UInt64, Int32, Int64, UnsafeMutableRawPointer?) -> Bool

/*
  Memory region mapped by uc_mem_map() and uc_mem_map_ptr()
  Retrieve the list of memory regions with uc_mem_regions()
*/
public typealias MemRegion = uc_mem_region

// All type of queries for uc_query() API.
public struct QueryType: Equatable {
    public var rawValue: uc_query_type

    public static func ==(lhs: QueryType, rhs: QueryType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    // Dynamically query current hardware mode.
    public static let mode = QueryType(rawValue: UC_QUERY_MODE)
    public static let pageSize = QueryType(rawValue: UC_QUERY_PAGE_SIZE)
}

// Dynamically query current hardware mode.

// Opaque storage for CPU context, used with uc_context_*()

/*
 Determine if the given architecture is supported by this library.

 @arch: architecture type (UC_ARCH_*)

 @return True if this library supports the given arch.
*/
public func archSupported(_ arch: Arch) -> Bool {
    return uc_arch_supported(arch.rawValue)
}

/*
 Create new instance of unicorn engine.

 @arch: architecture type (UC_ARCH_*)
 @mode: hardware mode. This is combined of UC_MODE_*
 @uc: pointer to uc_engine, which will be updated at return time

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func open(arch: Arch, mode: Mode = .littleEndian, _ uc: UnsafeMutablePointer<Engine?>!) throws {
    let err = uc_open(arch.rawValue, mode.rawValue, uc)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Close a Unicorn engine instance.
 NOTE: this must be called only when there is no longer any
 usage of @uc. This API releases some of @uc's cached memory, thus
 any use of the Unicorn API with @uc after it has been closed may
 crash your application. After this, @uc is invalid, and is no
 longer usable.

 @uc: pointer to a handle returned by uc_open()

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func close(_ uc: Engine!) throws {
    let err = uc_close(uc)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Query internal status of engine.

 @uc: handle returned by uc_open()
 @type: query type. See QueryType

 @result: save the internal status queried

 @return: error code of UnicornError enum type (UC_ERR_*, see above)
*/
public func query(_ uc: Engine!, _ type: QueryType, _ result: UnsafeMutablePointer<Int>!) throws {
    let err = uc_query(uc, type.rawValue, result)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Write to register.

 @uc: handle returned by uc_open()
 @regid:  register ID that is to be modified.
 @value:  pointer to the value that will set to register @regid

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func regWrite<Reg: Register>(_ uc: Engine!, regid: Reg, value: UnsafeRawPointer!) throws {
    let err = uc_reg_write(uc, regid.value, value)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Read register value.

 @uc: handle returned by uc_open()
 @regid:  register ID that is to be retrieved.
 @value:  pointer to a variable storing the register value.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func regRead<Reg: Register>(_ uc: Engine!, regid: Reg, value: UnsafeMutableRawPointer!) throws {
    let err = uc_reg_read(uc, regid.value, value)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Write multiple register values.

 @uc: handle returned by uc_open()
 @rges:  array of register IDs to store
 @value: pointer to array of register values
 @count: length of both *regs and *vals

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func regWriteBatch<Reg: Register>(_ uc: Engine!, _ regs: [Reg], _ vals: [UnsafeMutableRawPointer?]) throws {
    assert(regs.count == vals.count)
    var regs = regs.map({ $0.value })
    let err = uc_reg_write_batch(uc, &regs, vals, numericCast(regs.count))
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Read multiple register values.

 @uc: handle returned by uc_open()
 @rges:  array of register IDs to retrieve
 @value: pointer to array of values to hold registers
 @count: length of both *regs and *vals

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func regReadBatch<Reg: Register>(_ uc: Engine!, _ regs: [Reg], _ vals: [UnsafeMutableRawPointer?]) throws {
    assert(regs.count == vals.count)
    var regs = regs.map({ $0.value })
    var vals = vals
    let err = uc_reg_read_batch(uc, &regs, &vals, numericCast(regs.count))
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Write to a range of bytes in memory.

 @uc: handle returned by uc_open()
 @address: starting memory address of bytes to set.
 @bytes:   pointer to a variable containing data to be written to memory.
 @size:   size of memory to write to.

 NOTE: @bytes must be big enough to contain @size bytes.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memWrite(_ uc: Engine!, address: UInt64, bytes: UnsafeMutableRawBufferPointer) throws {
    let err = uc_mem_write(uc, address, bytes.baseAddress, bytes.count)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

public func memWrite(_ uc: Engine!, address: UInt64, bytes: [UInt8]) throws {
    let err = uc_mem_write(uc, address, bytes, bytes.count)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Read a range of bytes in memory.

 @uc: handle returned by uc_open()
 @address: starting memory address of bytes to get.
 @bytes:   pointer to a variable containing data copied from memory.
 @size:   size of memory to read.

 NOTE: @bytes must be big enough to contain @size bytes.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memRead(_ uc: Engine!, address: UInt64, bytes: UnsafeMutableRawBufferPointer) throws {
    let err = uc_mem_read(uc, address, bytes.baseAddress, bytes.count)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Emulate machine code in a specific duration of time.

 @uc: handle returned by uc_open()
 @begin: address where emulation starts
 @until: address where emulation stops (i.e when this address is hit)
 @timeout: duration to emulate the code (in microseconds). When this value is 0,
        we will emulate the code in infinite time, until the code is finished.
 @count: the number of instructions to be emulated. When this value is 0,
        we will emulate all the code available, until the code is finished.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func emuStart(_ uc: Engine!, begin: UInt64, until: UInt64, timeout: UInt64 = 0, count: Int = 0) throws {
    let err = uc_emu_start(uc, begin, until, timeout, count)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Stop emulation (which was started by uc_emu_start() API.
 This is typically called from callback functions registered via tracing APIs.

 @uc: handle returned by uc_open()

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func emuStop(_ uc: Engine!) throws {
    let err = uc_emu_stop(uc)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Unregister (remove) a hook callback.
 This API removes the hook callback registered by uc_hook_add().
 NOTE: this should be called only when you no longer want to trace.
 After this, @hh is invalid, and nolonger usable.

 @uc: handle returned by uc_open()
 @hh: handle returned by uc_hook_add()

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func hookDel(_ uc: Engine!, _ hh: Hook) throws {
    let err = uc_hook_del(uc, hh)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

public struct Prot: Equatable {
    public var rawValue: uc_prot

    public static func ==(lhs: Prot, rhs: Prot) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

   public static let none  = Prot(rawValue: UC_PROT_NONE)
   public static let read  = Prot(rawValue: UC_PROT_READ)
   public static let write = Prot(rawValue: UC_PROT_WRITE)
   public static let exec  = Prot(rawValue: UC_PROT_EXEC)
   public static let all   = Prot(rawValue: UC_PROT_ALL)
}

/*
 Map memory in for emulation.
 This API adds a memory region that can be used by emulation.

 @uc: handle returned by uc_open()
 @address: starting address of the new memory region to be mapped in.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the new memory region to be mapped in.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: Permissions for the newly mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memMap(_ uc: Engine!, address: UInt64, size: Int, perms: Prot) throws {
    let err = uc_mem_map(uc, address, size, perms.rawValue.rawValue)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Map existing host memory in for emulation.
 This API adds a memory region that can be used by emulation.

 @uc: handle returned by uc_open()
 @address: starting address of the new memory region to be mapped in.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the new memory region to be mapped in.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: Permissions for the newly mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.
 @ptr: pointer to host memory backing the newly mapped memory. This host memory is
    expected to be an equal or larger size than provided, and be mapped with at
    least PROT_READ | PROT_WRITE. If it is not, the resulting behavior is undefined.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memMapPtr(_ uc: Engine!, address: UInt64, size: Int, perms: Prot, _ ptr: UnsafeMutableRawPointer!) throws {
    let err = uc_mem_map_ptr(uc, address, size, perms.rawValue.rawValue, ptr)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Unmap a region of emulation memory.
 This API deletes a memory mapping from the emulation memory space.

 @uc: handle returned by uc_open()
 @address: starting address of the memory region to be unmapped.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the memory region to be modified.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memUnmap(_ uc: Engine!, address: UInt64, size: Int) throws {
    let err = uc_mem_unmap(uc, address, size)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Set memory permissions for emulation memory.
 This API changes permissions on an existing memory region.

 @uc: handle returned by uc_open()
 @address: starting address of the memory region to be modified.
    This address must be aligned to 4KB, or this will return with UC_ERR_ARG error.
 @size: size of the memory region to be modified.
    This size must be multiple of 4KB, or this will return with UC_ERR_ARG error.
 @perms: New permissions for the mapped region.
    This must be some combination of UC_PROT_READ | UC_PROT_WRITE | UC_PROT_EXEC,
    or this will return with UC_ERR_ARG error.

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memProtect(_ uc: Engine!, address: UInt64, size: Int, perms: Prot) throws {
    let err = uc_mem_protect(uc, address, size, perms.rawValue.rawValue)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Retrieve all memory regions mapped by uc_mem_map() and uc_mem_map_ptr()
 This API allocates memory for @regions, and user must free this memory later
 by free() to avoid leaking memory.
 NOTE: memory regions may be splitted by uc_mem_unmap()

 @uc: handle returned by uc_open()
 @regions: pointer to an array of MemRegion struct. This is allocated by
   Unicorn, and must be freed by user later with uc_free()
 @count: pointer to number of struct MemRegion contained in @regions

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func memRegions(_ uc: Engine!, regions: UnsafeMutablePointer<UnsafeMutablePointer<MemRegion>?>!, count: UnsafeMutablePointer<UInt32>!) throws {
    let err = uc_mem_regions(uc, regions, count)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Allocate a region that can be used with uc_context_{save,restore} to perform
 quick save/rollback of the CPU context, which includes registers and some
 internal metadata. Contexts may not be shared across engine instances with
 differing arches or modes.

 @uc: handle returned by uc_open()
 @context: pointer to a uc_engine*. This will be updated with the pointer to
   the new context on successful return of this function.
   Later, this allocated memory must be freed with uc_free().

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func contextAlloc(_ uc: Engine!, context: UnsafeMutablePointer<Context?>!) throws {
    let err = uc_context_alloc(uc, context)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Free the memory allocated by uc_context_alloc & uc_mem_regions.

 @mem: memory allocated by uc_context_alloc (returned in *context), or
       by uc_mem_regions (returned in *regions)

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func free(_ mem: UnsafeMutableRawPointer!) throws {
    let err = uc_free(mem)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Save a copy of the internal CPU context.
 This API should be used to efficiently make or update a saved copy of the
 internal CPU state.

 @uc: handle returned by uc_open()
 @context: handle returned by uc_context_alloc()

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func contextSave(_ uc: Engine!, context: Context) throws {
    let err = uc_context_save(uc, context)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}

/*
 Restore the current CPU context from a saved copy.
 This API should be used to roll the CPU context back to a previous
 state saved by uc_context_save().

 @uc: handle returned by uc_open()
 @buffer: handle returned by uc_context_alloc that has been used with uc_context_save

 @return UC_ERR_OK on success, or other value on failure (refer to UnicornError enum
   for detailed error).
*/
public func contextRestore(_ uc: Engine!, context: Context) throws {
    let err = uc_context_restore(uc, context)
    if err != UC_ERR_OK {
        throw UnicornError(rawValue: err)
    }
}
