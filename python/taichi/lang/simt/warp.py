from taichi.lang import impl


def all_nonzero(mask, predicate):
    return impl.call_internal("cuda_all_sync_i32",
                              mask,
                              predicate,
                              with_runtime_context=False)


def any_nonzero(mask, predicate):
    return impl.call_internal("cuda_any_sync_i32",
                              mask,
                              predicate,
                              with_runtime_context=False)


def unique(mask, predicate):
    return impl.call_internal("cuda_uni_sync_i32",
                              mask,
                              predicate,
                              with_runtime_context=False)


def ballot(predicate):
    return impl.call_internal("cuda_ballot_i32",
                              predicate,
                              with_runtime_context=False)


def shfl_sync_i32(mask, val, offset):
    # lane offset is 31 for warp size 32
    return impl.call_internal("cuda_shfl_sync_i32",
                              mask,
                              val,
                              offset,
                              31,
                              with_runtime_context=False)


def shfl_sync_f32(mask, val, offset):
    # lane offset is 31 for warp size 32
    return impl.call_internal("cuda_shfl_sync_f32",
                              mask,
                              val,
                              offset,
                              31,
                              with_runtime_context=False)


def shfl_up_i32(mask, val, offset):
    # lane offset is 0 for warp size 32
    return impl.call_internal("cuda_shfl_up_sync_i32",
                              mask,
                              val,
                              offset,
                              0,
                              with_runtime_context=False)


def shfl_up_f32(mask, val, offset):
    # lane offset is 0 for warp size 32
    return impl.call_internal("cuda_shfl_up_sync_f32",
                              mask,
                              val,
                              offset,
                              0,
                              with_runtime_context=False)


def shfl_down_i32(mask, val, offset):
    # lane offset is 31 for warp size 32
    return impl.call_internal("cuda_shfl_down_sync_i32",
                              mask,
                              val,
                              offset,
                              31,
                              with_runtime_context=False)


def shfl_down_f32(mask, val, offset):
    # lane offset is 31 for warp size 32
    return impl.call_internal("cuda_shfl_down_sync_f32",
                              mask,
                              val,
                              offset,
                              31,
                              with_runtime_context=False)


def shfl_xor_i32(mask, val, offset):
    return impl.call_internal("cuda_shfl_xor_sync_i32",
                              mask,
                              val,
                              offset,
                              31,
                              with_runtime_context=False)


def match_any():
    # TODO
    pass


def match_all():
    # TODO
    pass


def active_mask():
    return impl.call_internal("cuda_active_mask", with_runtime_context=False)


def sync(mask):
    return impl.call_internal("warp_barrier", mask, with_runtime_context=False)


__all__ = [
    'all_nonzero',
    'any_nonzero',
    'unique',
    'ballot',
    'shfl_sync_i32',
    'shfl_sync_f32',
    'shfl_up_i32',
    'shfl_up_f32',
    'shfl_down_i32',
    'shfl_down_f32',
    'shfl_xor_i32',
    'match_any',
    'match_all',
    'active_mask',
    'sync',
]
