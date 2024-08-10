int main() {
    int cnt = 0;
    for (int i = 0; i < 10; i = i + 1) {
        for (int j = 0; j < 10; j = j + 1) {
            if (j == 3)
                break;
            cnt = cnt + 1;
        }
    }
    return cnt;
}