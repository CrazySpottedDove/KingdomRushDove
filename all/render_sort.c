// render_sort.c
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

// merge 函数
static void merge(RenderFrameFFI* arr, RenderFrameFFI* tmp, int left, int mid, int right)
{
    int i = left, j = mid, k = left;
    while (i < mid && j < right) {
        if (cmp(&arr[i], &arr[j]) <= 0) {
            tmp[k++] = arr[i++];
        }
        else {
            tmp[k++] = arr[j++];
        }
    }
    while (i < mid) tmp[k++] = arr[i++];
    while (j < right) tmp[k++] = arr[j++];
    for (i = left; i < right; i++) arr[i] = tmp[i];
}

// 递归 merge sort
static void merge_sort_recursive(RenderFrameFFI* arr, RenderFrameFFI* tmp, int left, int right)
{
    if (right - left <= 1) return;
    int mid = (left + right) / 2;
    merge_sort_recursive(arr, tmp, left, mid);
    merge_sort_recursive(arr, tmp, mid, right);
    merge(arr, tmp, left, mid, right);
}

// 外部接口
void ffi_sort(RenderFrameFFI* arr, RenderFrameFFI* tmp, int n)
{
    merge_sort_recursive(arr, tmp, 0, n);
}