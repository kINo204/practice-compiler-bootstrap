int main() {
    int a = 2;
    {
        a = 3;
        {
            a = 4;
            {
                a = 5;
            }
        }
    }
    return a;
}
