int main() {
    int cnt = 0;
    for (int i = 0; i < 3; i = i + 1)
    {
        for (int j = 0; j < 4; j = j + 1)
            cnt = cnt + 1;
    }
    return cnt;
}