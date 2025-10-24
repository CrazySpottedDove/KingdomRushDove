// render_sort.c
#include <string.h>

typedef struct
{
    double sort_y;
    double pos_x;
    int    z;
    int    draw_order;
    int    lua_index;
} RenderFrameFFI;

static int cmp(const RenderFrameFFI* a, const RenderFrameFFI* b)
{
    if (a->z != b->z) return (a->z < b->z) ? -1 : 1;
    if (a->sort_y != b->sort_y) return (a->sort_y > b->sort_y) ? -1 : 1;
    if (a->draw_order != b->draw_order) return (a->draw_order < b->draw_order) ? -1 : 1;
    if (a->pos_x != b->pos_x) return (a->pos_x < b->pos_x) ? -1 : 1;
    return 0;
}

#define MIN_RUN 32

// 插入排序
static void insertion_sort(RenderFrameFFI* arr, int left, int right)
{
    for (int i = left + 1; i <= right; i++) {
        RenderFrameFFI temp = arr[i];
        int            j    = i - 1;
        while (j >= left && cmp(&arr[j], &temp) > 0) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = temp;
    }
}

// 合并两个有序区间
static void merge(RenderFrameFFI* arr, RenderFrameFFI* tmp, int left, int mid, int right)
{
    memcpy(tmp + left, arr + left, (right - left + 1) * sizeof(RenderFrameFFI));

    int i = left, j = mid + 1, k = left;
    while (i <= mid && j <= right) {
        if (cmp(&tmp[i], &tmp[j]) <= 0) {
            arr[k++] = tmp[i++];
        }
        else {
            arr[k++] = tmp[j++];
        }
    }
    while (i <= mid) arr[k++] = tmp[i++];
    while (j <= right) arr[k++] = tmp[j++];
}

// Timsort 主函数
void ffi_sort(RenderFrameFFI* arr, RenderFrameFFI* tmp, int n)
{
    // 1. 对每个子数组使用插入排序
    for (int i = 0; i < n; i += MIN_RUN) {
        int right = (i + MIN_RUN - 1 < n - 1) ? i + MIN_RUN - 1 : n - 1;
        insertion_sort(arr, i, right);
    }

    // 2. 合并子数组
    for (int size = MIN_RUN; size < n; size *= 2) {
        for (int left = 0; left < n; left += 2 * size) {
            int mid   = left + size - 1;
            int right = (left + 2 * size - 1 < n - 1) ? left + 2 * size - 1 : n - 1;

            if (mid < right) {
                merge(arr, tmp, left, mid, right);
            }
        }
    }
}