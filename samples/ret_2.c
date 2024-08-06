int main() {
    int a;
    a = 2;
    {
        int a;
        a = 66;
    }
    int b;
    b = 4;
    return a + b;
}
