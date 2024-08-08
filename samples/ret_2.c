int main() {
    int i;
    for (i = 0;; i = i + 1) {
        if (i > 5)
            break;
        continue;
    }
    return i;
}